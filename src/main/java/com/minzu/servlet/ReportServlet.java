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
 *   POST action=submit  : 用户举报商品（product_id + reason），防重复举报
 *   GET  （管理员）      : 查看所有举报列表
 *   POST action=takedown: 管理员下架商品
 *   POST action=dismiss : 管理员驳回举报（商品正常）
 *
 * 注意：reports 表实际列名为 report_status / report_reason / report_detail
 *       枚举值为 PENDING / APPROVED / REJECTED / CLOSED
 *       驳回用 REJECTED，下架/通过用 APPROVED
 */
@WebServlet("/report")
public class ReportServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User loginUser = getLoginUser(req, resp);
        if (loginUser == null) return;
        if (!"ADMIN".equals(loginUser.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return;
        }

        // 使用数据库真实列名：report_status / report_reason
        String sql =
            "SELECT r.report_id, r.product_id, r.report_reason AS reason, " +
            "r.report_detail, r.report_status AS status, r.created_at, " +
            "r.handler_admin_id, r.handle_result, r.handled_at, " +
            "p.title AS product_title, p.publish_status, p.cover_image_url, " +
            "u.nickname AS reporter_name " +
            "FROM reports r " +
            "LEFT JOIN products p ON r.product_id = p.product_id " +
            "LEFT JOIN users u ON r.reporter_id = u.user_id " +
            "ORDER BY FIELD(r.report_status, 'PENDING', 'APPROVED', 'REJECTED', 'CLOSED'), r.created_at DESC";

        List<Map<String, Object>> reportList = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("reportId",      rs.getInt("report_id"));
                row.put("productId",     rs.getInt("product_id"));
                row.put("reason",        rs.getString("reason"));       // alias: report_reason
                row.put("reportDetail",  rs.getString("report_detail"));
                row.put("status",        rs.getString("status"));       // alias: report_status
                row.put("createdAt",     rs.getTimestamp("created_at"));
                row.put("handledAt",     rs.getTimestamp("handled_at"));
                row.put("handleResult",  rs.getString("handle_result"));
                row.put("productTitle",  rs.getString("product_title"));
                row.put("publishStatus", rs.getString("publish_status"));
                row.put("coverImageUrl", rs.getString("cover_image_url"));
                row.put("reporterName",  rs.getString("reporter_name"));
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
            submitReport(req, resp, loginUser);
        } else if ("takedown".equals(action)) {
            if (!requireAdmin(loginUser, req, resp)) {
                return;
            }
            takedownProduct(req, resp, loginUser);
        } else if ("dismiss".equals(action)) {
            if (!requireAdmin(loginUser, req, resp)) {
                return;
            }
            dismissReport(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/product-list");
        }
    }

    /** 普通用户举报商品（防止重复举报） */
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

        try (Connection conn = DBUtil.getConnection()) {
            // 校验商品存在且不能被卖家本人举报
            String checkSql = "SELECT seller_id FROM products WHERE product_id = ? AND IFNULL(is_deleted, 0) = 0";
            try (PreparedStatement ps = conn.prepareStatement(checkSql)) {
                ps.setInt(1, productId);
                try (ResultSet rs = ps.executeQuery()) {
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

            // 防止重复举报（同一用户对同一商品只能有一条 PENDING 举报）
            // 使用真实列名 report_status
            String dupSql = "SELECT report_id FROM reports " +
                    "WHERE reporter_id = ? AND product_id = ? AND report_status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(dupSql)) {
                ps.setInt(1, loginUser.getUserId());
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.getSession().setAttribute("errorMsg", "您已举报过该商品，请等待管理员处理");
                        resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);
                        return;
                    }
                }
            }

            // 插入时使用 report_reason 列
            String insertSql = "INSERT INTO reports (reporter_id, product_id, report_reason) VALUES (?, ?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql)) {
                ps.setInt(1, loginUser.getUserId());
                ps.setInt(2, productId);
                ps.setString(3, reason.trim());
                ps.executeUpdate();
            }

            req.getSession().setAttribute("successMsg", "举报已提交，管理员将尽快处理");
            resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);

        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "举报失败：" + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/product-detail?id=" + productId);
        }
    }

    /** 管理员下架商品（举报属实），将 report_status 改为 APPROVED */
    private void takedownProduct(HttpServletRequest req, HttpServletResponse resp, User admin)
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

                // 标记举报为已处理（使用真实列名 report_status，值改为 APPROVED）
                if (reportIdStr != null && !reportIdStr.trim().isEmpty()) {
                    int reportId = Integer.parseInt(reportIdStr.trim());
                    String updateReportSql = "UPDATE reports SET report_status = 'APPROVED', " +
                            "handler_admin_id = ?, handled_at = NOW() " +
                            "WHERE report_id = ? AND product_id = ?";
                    try (PreparedStatement ps = conn.prepareStatement(updateReportSql)) {
                        ps.setInt(1, admin.getUserId());
                        ps.setInt(2, reportId);
                        ps.setInt(3, productId);
                        ps.executeUpdate();
                    }
                }

                // 通知卖家商品被下架
                String notifySql = "INSERT INTO notifications (user_id, content) " +
                        "SELECT seller_id, CONCAT('您的商品《', title, '》因违规被管理员下架') " +
                        "FROM products WHERE product_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(notifySql)) {
                    ps.setInt(1, productId);
                    ps.executeUpdate();
                }

                conn.commit();
                req.getSession().setAttribute("successMsg", "商品已下架，卖家已收到通知");
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

    /** 管理员驳回举报，将 report_status 改为 REJECTED */
    private void dismissReport(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {

        String reportIdStr = req.getParameter("reportId");
        if (reportIdStr == null || reportIdStr.trim().isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/report");
            return;
        }

        int reportId;
        try {
            reportId = Integer.parseInt(reportIdStr.trim());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/report");
            return;
        }

        try (Connection conn = DBUtil.getConnection()) {
            // 使用真实列名 report_status，驳回用 REJECTED
            String sql = "UPDATE reports SET report_status = 'REJECTED', handled_at = NOW() " +
                    "WHERE report_id = ? AND report_status = 'PENDING'";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, reportId);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    req.getSession().setAttribute("successMsg", "举报已驳回");
                } else {
                    req.getSession().setAttribute("errorMsg", "举报不存在或已处理");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/report");
    }

    private boolean requireAdmin(User user, HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        if (!"ADMIN".equals(user.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return false;
        }
        return true;
    }

    private User getLoginUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) resp.sendRedirect(req.getContextPath() + "/login");
        return u;
    }
}
