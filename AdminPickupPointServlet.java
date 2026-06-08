package com.minzu.servlet;

import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

/**
 * /admin/pickup-points - 自提点管理
 * GET:  查询所有自提点（含禁用），渲染管理页面
 * POST: 处理 add / toggle / delete 操作
 */
@WebServlet("/admin/pickup-points")
public class AdminPickupPointServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        if (!isAdmin(req, resp)) return;

        List<Map<String, Object>> pointList = new ArrayList<>();
        String successMsg = (String) req.getSession().getAttribute("successMsg");
        if (successMsg != null) {
            req.setAttribute("successMsg", successMsg);
            req.getSession().removeAttribute("successMsg");
        }
        String errorMsg = (String) req.getAttribute("errorMsg");

        String sql = "SELECT pickup_point_id, point_name, campus_area, address_detail, " +
                     "contact_phone, open_time_desc, is_enabled, created_at, updated_at " +
                     "FROM pickup_points ORDER BY pickup_point_id";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> point = new LinkedHashMap<>();
                point.put("id", rs.getLong("pickup_point_id"));
                point.put("name", rs.getString("point_name"));
                point.put("campusArea", rs.getString("campus_area"));
                point.put("address", rs.getString("address_detail"));
                point.put("phone", rs.getString("contact_phone"));
                point.put("openTime", rs.getString("open_time_desc"));
                point.put("enabled", rs.getBoolean("is_enabled"));
                point.put("createdAt", rs.getTimestamp("created_at"));
                point.put("updatedAt", rs.getTimestamp("updated_at"));
                pointList.add(point);
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("errorMsg", "加载自提点列表失败：" + e.getMessage());
        }

        req.setAttribute("pointList", pointList);
        req.getRequestDispatcher("/admin-pickup-points.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        if (!isAdmin(req, resp)) return;

        String action = req.getParameter("action");
        if (action == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
            return;
        }

        switch (action) {
            case "add":
                handleAdd(req, resp);
                break;
            case "toggle":
                handleToggle(req, resp);
                break;
            case "delete":
                handleDelete(req, resp);
                break;
            default:
                resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String name = req.getParameter("pointName");
        String campusArea = req.getParameter("campusArea");
        String address = req.getParameter("addressDetail");
        String phone = req.getParameter("contactPhone");
        String openTime = req.getParameter("openTimeDesc");

        if (name == null || name.trim().isEmpty() || address == null || address.trim().isEmpty()) {
            req.getSession().setAttribute("errorMsg", "自提点名称和详细地址不能为空");
            resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
            return;
        }

        String sql = "INSERT INTO pickup_points (point_name, campus_area, address_detail, contact_phone, open_time_desc, is_enabled) " +
                     "VALUES (?, ?, ?, ?, ?, 1)";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name.trim());
            ps.setString(2, campusArea != null ? campusArea.trim() : null);
            ps.setString(3, address.trim());
            ps.setString(4, phone != null ? phone.trim() : null);
            ps.setString(5, openTime != null ? openTime.trim() : null);
            ps.executeUpdate();
            req.getSession().setAttribute("successMsg", "自提点添加成功");
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "添加失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
    }

    private void handleToggle(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("pointId");
        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
            return;
        }

        try {
            long pointId = Long.parseLong(idStr);
            String sql = "UPDATE pickup_points SET is_enabled = NOT is_enabled WHERE pickup_point_id = ?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, pointId);
                ps.executeUpdate();
                req.getSession().setAttribute("successMsg", "状态已更新");
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "操作失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String idStr = req.getParameter("pointId");
        if (idStr == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
            return;
        }

        try {
            long pointId = Long.parseLong(idStr);

            // 检查是否有商品关联此自提点
            String checkSql = "SELECT COUNT(*) FROM products WHERE pickup_point_id = ? AND IFNULL(is_deleted, 0) = 0";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement checkPs = conn.prepareStatement(checkSql)) {
                checkPs.setLong(1, pointId);
                try (ResultSet rs = checkPs.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        req.getSession().setAttribute("errorMsg", "该自提点下还有商品，请先移除关联商品后再删除");
                        resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
                        return;
                    }
                }

                String sql = "DELETE FROM pickup_points WHERE pickup_point_id = ?";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setLong(1, pointId);
                    ps.executeUpdate();
                    req.getSession().setAttribute("successMsg", "自提点已删除");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            req.getSession().setAttribute("errorMsg", "删除失败：" + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/admin/pickup-points");
    }

    private boolean isAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return false;
        }
        if (!"ADMIN".equals(loginUser.getRoleCode())) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp");
            return false;
        }
        return true;
    }
}
