package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/admin/products")
public class AdminProductReviewServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getAdminUser(req, resp);
        if (loginUser == null) return;

        String tab = req.getParameter("tab");
        if (tab == null) tab = "on_sale";
        String keyword = req.getParameter("keyword");
        if (keyword == null) keyword = "";

        String statusFilter;
        switch (tab) {
            case "off_shelf": statusFilter = "OFF_SHELF"; break;
            case "rejected":  statusFilter = "REJECTED";  break;
            default:          statusFilter = "ON_SALE";    tab = "on_sale"; break;
        }

        String sql =
            "SELECT p.product_id, p.title, p.price, p.publish_status, p.created_at, " +
            "p.cover_image_url, p.condition_level, c.category_name, " +
            "u.real_name AS seller_name, u.student_or_staff_no " +
            "FROM products p " +
            "LEFT JOIN users u ON p.seller_id=u.user_id " +
            "LEFT JOIN categories c ON p.category_id=c.category_id " +
            "WHERE p.publish_status=? AND IFNULL(p.is_deleted,0)=0 ";

        if (!keyword.trim().isEmpty()) {
            sql += "AND (p.title LIKE ? OR u.real_name LIKE ? OR u.student_or_staff_no LIKE ?) ";
        }
        sql += "ORDER BY p.created_at DESC";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            int idx = 1;
            ps.setString(idx++, statusFilter);
            if (!keyword.trim().isEmpty()) {
                String like = "%" + keyword.trim() + "%";
                ps.setString(idx++, like);
                ps.setString(idx++, like);
                ps.setString(idx++, like);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("productId",     rs.getInt("product_id"));
                    row.put("title",         rs.getString("title"));
                    row.put("price",         rs.getBigDecimal("price"));
                    row.put("publishStatus", rs.getString("publish_status"));
                    row.put("createdAt",     rs.getTimestamp("created_at"));
                    row.put("coverImageUrl", rs.getString("cover_image_url"));
                    row.put("conditionLevel",rs.getString("condition_level"));
                    row.put("categoryName",  rs.getString("category_name"));
                    row.put("sellerName",    rs.getString("seller_name"));
                    row.put("sellerNo",      rs.getString("student_or_staff_no"));
                    list.add(row);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载商品列表失败：" + e.getMessage());
        }

        req.setAttribute("productList", list);
        req.setAttribute("tab", tab);
        req.setAttribute("keyword", keyword);
        req.getRequestDispatcher("/admin-product-review.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User loginUser = getAdminUser(req, resp);
        if (loginUser == null) return;

        String action = req.getParameter("action");
        String tab    = req.getParameter("tab");
        if (tab == null) tab = "on_sale";

        if ("takedown".equals(action)) {
            handleBatchTakedown(req, resp, tab);
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/products?tab=" + tab);
    }

    private void handleBatchTakedown(HttpServletRequest req, HttpServletResponse resp, String tab)
            throws IOException {
        String idsParam = req.getParameter("ids");
        if (idsParam == null || idsParam.trim().isEmpty()) {
            req.getSession().setAttribute("errorMsg", "请选择要下架的商品");
            resp.sendRedirect(req.getContextPath() + "/admin/products?tab=" + tab);
            return;
        }

        String[] idArr = idsParam.split(",");
        int successCount = 0;

        try (Connection conn = DBUtil.getConnection()) {
            String infoSql = "SELECT seller_id, title FROM products WHERE product_id = ?";
            String updateSql = "UPDATE products SET publish_status = 'OFF_SHELF', updated_at = NOW() WHERE product_id = ? AND publish_status = 'ON_SALE'";

            for (String idStr : idArr) {
                int productId;
                try { productId = Integer.parseInt(idStr.trim()); }
                catch (NumberFormatException e) { continue; }

                int sellerId = 0;
                String productTitle = "未知商品";
                try (PreparedStatement infoPs = conn.prepareStatement(infoSql)) {
                    infoPs.setInt(1, productId);
                    try (ResultSet rs = infoPs.executeQuery()) {
                        if (rs.next()) {
                            sellerId = rs.getInt("seller_id");
                            productTitle = rs.getString("title");
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                    ps.setInt(1, productId);
                    int rows = ps.executeUpdate();
                    if (rows > 0) {
                        successCount++;
                        sendNotification(sellerId, "您的商品「" + productTitle + "」已被管理员下架");
                    }
                }
            }

            if (successCount > 0) {
                req.getSession().setAttribute("successMsg", "已成功下架 " + successCount + " 件商品");
            } else {
                req.getSession().setAttribute("errorMsg", "操作失败，商品状态可能已变更");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/products?tab=" + tab);
    }

    private User getAdminUser(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User u = session == null ? null : (User) session.getAttribute("loginUser");
        if (u == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return null;
        }
        if (!"ADMIN".equals(u.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return null;
        }
        return u;
    }

    private void sendNotification(int userId, String content) {
        String sql = "INSERT INTO notifications (user_id, content) VALUES (?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
