package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /dispute - 订单纠纷系统
 *
 * GET  ?action=list        买家查看自己发起的纠纷列表
 * GET  ?action=admin       管理员查看所有待处理纠纷
 * POST action=submit       买家发起纠纷（orderId + reason）
 * POST action=resolve      管理员裁决纠纷（disputeId + result: REFUND|RELEASE + adminNote）
 */
@WebServlet("/dispute")
public class DisputeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String action = req.getParameter("action");

        if ("admin".equals(action)) {
            // 管理员查看所有纠纷
            if (!"ADMIN".equals(loginUser.getRoleCode())) {
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
                return;
            }
            listDisputesForAdmin(req, resp);
        } else {
            // 买家查看自己的纠纷
            listMyDisputes(req, resp, loginUser);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String action = req.getParameter("action");

        if ("submit".equals(action)) {
            submitDispute(req, resp, loginUser);
        } else if ("resolve".equals(action)) {
            if (!"ADMIN".equals(loginUser.getRoleCode())) {
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
                return;
            }
            resolveDispute(req, resp, loginUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/orders");
        }
    }

    /** 买家/卖家发起纠纷 */
    private void submitDispute(HttpServletRequest req, HttpServletResponse resp, User loginUser)
            throws IOException {
        String orderIdStr = req.getParameter("orderId");
        String reason     = req.getParameter("reason");

        if (orderIdStr == null || orderIdStr.trim().isEmpty()
                || reason == null || reason.trim().isEmpty()) {
            req.getSession().setAttribute("errorMsg", "请填写纠纷原因");
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        int orderId;
        try {
            orderId = Integer.parseInt(orderIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/orders");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 校验订单归属（买家或卖家均可发起），且状态为 CREATED 或 PAID_OFFLINE
            String checkSql = "SELECT order_id, seller_id, order_status FROM orders " +
                    "WHERE order_id = ? AND (buyer_id = ? OR seller_id = ?) " +
                    "AND order_status IN ('CREATED','PAID_OFFLINE')";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, orderId);
                ps.setInt(2, loginUser.getUserId());
                ps.setInt(3, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        req.getSession().setAttribute("errorMsg", "无法对该订单发起纠纷（订单不存在或状态不符）");
                        resp.sendRedirect(req.getContextPath() + "/orders");
                        return;
                    }
                }
            }

            // 防止重复发起
            String dupSql = "SELECT dispute_id FROM disputes WHERE order_id = ? AND status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(dupSql)) {
                ps.setInt(1, orderId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.getSession().setAttribute("errorMsg", "该订单已有待处理的纠纷，请勿重复提交");
                        resp.sendRedirect(req.getContextPath() + "/orders");
                        return;
                    }
                }
            }

            conn.setAutoCommit(false);
            try {
                // 插入纠纷记录
                String insertSql = "INSERT INTO disputes (order_id, applicant_id, reason) VALUES (?, ?, ?)";
                try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                    ps.setInt(1, orderId);
                    ps.setInt(2, loginUser.getUserId());
                    ps.setString(3, reason.trim());
                    ps.executeUpdate();
                }

                // 更新订单状态为 DISPUTED
                String updateOrderSql = "UPDATE orders SET order_status = 'DISPUTED' WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOrderSql)) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }

                // 通知管理员（写入 notifications 给所有 ADMIN）
                String notifySql = "INSERT INTO notifications (user_id, content) " +
                        "SELECT user_id, CONCAT('订单 #', ?, ' 有新的纠纷申请，请尽快处理') " +
                        "FROM users WHERE role_code = 'ADMIN'";
                try (PreparedStatement ps = conn.prepareStatement(notifySql)) {
                    ps.setInt(1, orderId);
                    ps.executeUpdate();
                }

                conn.commit();
                req.getSession().setAttribute("successMsg", "纠纷已提交，管理员将尽快处理");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "提交失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/orders");
    }

    /** 管理员裁决纠纷 */
    private void resolveDispute(HttpServletRequest req, HttpServletResponse resp, User admin)
            throws IOException {
        String disputeIdStr = req.getParameter("disputeId");
        String result       = req.getParameter("result");   // REFUND | RELEASE
        String adminNote    = req.getParameter("adminNote");

        if (disputeIdStr == null || (!"REFUND".equals(result) && !"RELEASE".equals(result))) {
            resp.sendRedirect(req.getContextPath() + "/dispute?action=admin");
            return;
        }

        int disputeId;
        try {
            disputeId = Integer.parseInt(disputeIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/dispute?action=admin");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 查纠纷对应的 orderId、buyerId、sellerId
            String fetchSql = "SELECT d.order_id, o.buyer_id, o.seller_id " +
                    "FROM disputes d JOIN orders o ON d.order_id = o.order_id " +
                    "WHERE d.dispute_id = ? AND d.status = 'PENDING'";
            int orderId = 0, buyerId = 0, sellerId = 0;
            try (PreparedStatement ps = conn.prepareStatement(fetchSql)) {
                ps.setInt(1, disputeId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        req.getSession().setAttribute("errorMsg", "纠纷不存在或已处理");
                        resp.sendRedirect(req.getContextPath() + "/dispute?action=admin");
                        return;
                    }
                    orderId  = rs.getInt("order_id");
                    buyerId  = rs.getInt("buyer_id");
                    sellerId = rs.getInt("seller_id");
                }
            }

            conn.setAutoCommit(false);
            try {
                // 更新纠纷状态
                String updateDispute = "UPDATE disputes SET status = ?, admin_note = ?, resolved_at = NOW() " +
                        "WHERE dispute_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateDispute)) {
                    ps.setString(1, result);  // REFUND or RELEASE
                    ps.setString(2, adminNote != null ? adminNote.trim() : "");
                    ps.setInt(3, disputeId);
                    ps.executeUpdate();
                }

                // 根据裁决更新订单状态
                String newOrderStatus = "REFUND".equals(result) ? "REFUNDED" : "COMPLETED";
                String updateOrder = "UPDATE orders SET order_status = ? WHERE order_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(updateOrder)) {
                    ps.setString(1, newOrderStatus);
                    ps.setInt(2, orderId);
                    ps.executeUpdate();
                }

                // 如果是退款，商品重新上架
                if ("REFUND".equals(result)) {
                    String reshelf = "UPDATE products SET publish_status = 'ON_SALE' " +
                            "WHERE product_id = (SELECT product_id FROM orders WHERE order_id = ?)";
                    try (PreparedStatement ps = conn.prepareStatement(reshelf)) {
                        ps.setInt(1, orderId);
                        ps.executeUpdate();
                    }
                }

                // 通知买家
                String buyerMsg = "REFUND".equals(result)
                        ? "您对订单 #" + orderId + " 发起的纠纷已裁决：同意退款，商品已重新上架"
                        : "您对订单 #" + orderId + " 发起的纠纷已裁决：交易正常，订单已确认";
                insertNotification(conn, buyerId, buyerMsg);

                // 通知卖家
                String sellerMsg = "REFUND".equals(result)
                        ? "订单 #" + orderId + " 经管理员裁决：买家退款成功，商品已重新上架"
                        : "订单 #" + orderId + " 经管理员裁决：交易正常，订单已确认";
                insertNotification(conn, sellerId, sellerMsg);

                conn.commit();
                req.getSession().setAttribute("successMsg",
                        "REFUND".equals(result) ? "已裁决：同意退款" : "已裁决：交易正常");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "裁决失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/dispute?action=admin");
    }

    /** 买家查看自己的纠纷列表 */
    private void listMyDisputes(HttpServletRequest req, HttpServletResponse resp, User loginUser)
            throws ServletException, IOException {
        String sql = "SELECT d.dispute_id, d.order_id, d.reason, d.status, d.admin_note, " +
                "d.created_at, d.resolved_at, p.title AS product_title " +
                "FROM disputes d " +
                "JOIN orders o ON d.order_id = o.order_id " +
                "JOIN products p ON o.product_id = p.product_id " +
                "WHERE d.applicant_id = ? " +
                "ORDER BY d.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("disputeId",    rs.getInt("dispute_id"));
                    row.put("orderId",      rs.getInt("order_id"));
                    row.put("reason",       rs.getString("reason"));
                    row.put("status",       rs.getString("status"));
                    row.put("adminNote",    rs.getString("admin_note"));
                    row.put("createdAt",    rs.getTimestamp("created_at"));
                    row.put("resolvedAt",   rs.getTimestamp("resolved_at"));
                    row.put("productTitle", rs.getString("product_title"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载纠纷列表失败：" + e.getMessage());
        }

        req.setAttribute("disputeList", list);
        req.getRequestDispatcher("/my-disputes.jsp").forward(req, resp);
    }

    /** 管理员查看所有纠纷 */
    private void listDisputesForAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String sql = "SELECT d.dispute_id, d.order_id, d.reason, d.status, d.admin_note, " +
                "d.created_at, d.resolved_at, " +
                "p.title AS product_title, " +
                "buyer.nickname AS buyer_name, " +
                "seller.nickname AS seller_name " +
                "FROM disputes d " +
                "JOIN orders o ON d.order_id = o.order_id " +
                "JOIN products p ON o.product_id = p.product_id " +
                "JOIN users buyer ON o.buyer_id = buyer.user_id " +
                "JOIN users seller ON o.seller_id = seller.user_id " +
                "ORDER BY FIELD(d.status,'PENDING','REFUND','RELEASE'), d.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("disputeId",    rs.getInt("dispute_id"));
                row.put("orderId",      rs.getInt("order_id"));
                row.put("reason",       rs.getString("reason"));
                row.put("status",       rs.getString("status"));
                row.put("adminNote",    rs.getString("admin_note"));
                row.put("createdAt",    rs.getTimestamp("created_at"));
                row.put("resolvedAt",   rs.getTimestamp("resolved_at"));
                row.put("productTitle", rs.getString("product_title"));
                row.put("buyerName",    rs.getString("buyer_name"));
                row.put("sellerName",   rs.getString("seller_name"));
                list.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载纠纷列表失败：" + e.getMessage());
        }

        req.setAttribute("disputeList", list);
        req.getRequestDispatcher("/admin-disputes.jsp").forward(req, resp);
    }

    private void insertNotification(Connection conn, int userId, String content) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, content) VALUES (?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.executeUpdate();
        }
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) resp.sendRedirect(req.getContextPath() + "/login");
        return u;
    }
}
