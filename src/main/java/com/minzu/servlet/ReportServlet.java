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
 * /report - 违规举报与下架
 *   POST action=submit: 用户举报商品（product_id + reason），写入 reports 表
 *   GET （管理员）: 查看所有举报列表
 *   POST action=takedown: 管理员下架商品（products.publish_status -> OFF_SHELF）
 */
@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        // 管理员登录校验
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;
        if (!"ADMIN".equals(loginUser.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        // 查询所有举报列表
        String sql =
            "SELECT r.report_id, r.product_id, r.reason, r.status, r.created_at, " +
            "p.title AS product_title, p.publish_status, p.cover_image_url, " +
            "u.nickname AS reporter_name " +
            "FROM reports r " +
            "LEFT JOIN products p ON r.product_id = p.product_id " +
            "LEFT JOIN users u ON r.reporter_id = u.user_id " +
            "ORDER BY FIELD(r.status, 'PENDING', 'HANDLED'), r.created_at DESC";

        List<Map<String, Object>> reportList = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("reportId",     rs.getInt("report_id"));
                row.put("productId",    rs.getInt("product_id"));
                row.put("reason",       rs.getString("reason"));
                row.put("status",       rs.getString("status"));
                row.put("createdAt",    rs.getTimestamp("created_at"));
                row.put("productTitle", rs.getString("product_title"));
                row.put("publishStatus",rs.getString("publish_status"));
                row.put("coverImageUrl",rs.getString("cover_image_url"));
                row.put("reporterName", rs.getString("reporter_name"));
                reportList.add(row);
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载举报列表失败：" + e.getMessage());
        }

        req.setAttribute("reportList", reportList);
        req.getRequestDispatcher("/admin-reports.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;

        String action = req.getParameter("action");

        if ("submit".equals(action)) {
            // 普通用户提交举报
            submitReport(req, resp, loginUser);
        } else if ("takedown".equals(action)) {
            // 管理员下架商品
            if (!"ADMIN".equals(loginUser.getRoleCode())) {
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
                return;
            }
            takedownProduct(req, resp, loginUser);
        } else {
            resp.sendRedirect(req.getContextPath() + "/product-list");
        }
    }

    /**
     * 普通用户举报商品
     */
    private void submitReport(HttpServletRequest req, HttpServletResponse resp, User loginUser)
            throws IOException {

        String productIdStr = req.getParameter("productId");
        String reason = req.getParameter("reason");

        if (productIdStr == null || productIdStr.trim().isEmpty()
                || reason == null || reason.trim().isEmpty()) {
            req.getSession().setAttribute("errorMsg", "举报失败：请填写举报原因");
            resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productIdStr);
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMsg", "举报失败：商品ID格式错误");
            resp.sendRedirect(req.getContextPath() + "/product-list");
            return;
        }

        // 校验商品存在且不能被卖家本人举报
        String checkSql = "SELECT seller_id, publish_status FROM products WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0";
        String insertSql = "INSERT INTO reports (reporter_id, product_id, reason) VALUES (?, ?, ?)";

        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setInt(1, productId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (!rs.next()) {
                        req.getSession().setAttribute("errorMsg", "举报失败：商品不存在");
                        resp.sendRedirect(req.getContextPath() + "/product-list");
                        return;
                    }
                    if (rs.getInt("seller_id") == loginUser.getUserId()) {
                        req.getSession().setAttribute("errorMsg", "不能举报自己的商品");
                        resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);
                        return;
                    }
                }
            }

            try (PreparedStatement insertPs = conn.prepareStatement(insertSql)) {
                insertPs.setInt(1, loginUser.getUserId());
                insertPs.setInt(2, productId);
                insertPs.setString(3, reason.trim());
                insertPs.executeUpdate();
            }

            req.getSession().setAttribute("successMsg", "举报已提交，管理员将尽快处理");
            resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "举报失败：" + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);
        }
    }

    /**
     * 管理员下架商品
     */
    private void takedownProduct(HttpServletRequest req, HttpServletResponse resp, User loginUser)
            throws IOException {

        String productIdStr = req.getParameter("productId");
        String reportIdStr  = req.getParameter("reportId");

        if (productIdStr == null || productIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/report");
            return;
        }

        int productId;
        try {
            productId = Integer.parseInt(productIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/report");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                // 下架商品
                String updateSql = "UPDATE products SET publish_status = 'OFF_SHELF' " +
                        "WHERE product_id = ? AND publish_status != 'SOLD' AND IFNULL(is_deleted, 0) = 0";
                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                // 标记举报为已处理
                if (reportIdStr != null && !reportIdStr.trim().isEmpty()) {
                    int reportId = Integer.parseInt(reportIdStr.trim());
                    String updateReportSql = "UPDATE reports SET status = 'HANDLED' WHERE report_id = ? AND product_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateReportSql)) {
                        ps.setInt(1, reportId);
                        ps.setInt(2, productId);
                        ps.executeUpdate();
                    }
                }

                conn.commit();
                req.getSession().setAttribute("successMsg", "商品已下架");
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "下架失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/report");
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
        }
        return u;
    }
}
