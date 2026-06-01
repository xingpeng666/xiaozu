package com.minzu.servlet;

import com.minzu.entity.BrowseHistory;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

@WebServlet("/browse-history")
public class BrowseHistoryServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr.trim()));
        } catch (NumberFormatException ignored) {}
        int pageSize = 20;
        int offset = (page - 1) * pageSize;

        // 总数查询
        String countSql = "SELECT COUNT(*) FROM browse_history WHERE user_id = ?";
        int totalCount = 0;
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(countSql)) {
            ps.setLong(1, loginUser.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCount = rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }

        int totalPages = (int) Math.ceil((double) totalCount / pageSize);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;

        String sql =
            "SELECT bh.id, bh.product_id, bh.browse_time, " +
            "       p.title, p.cover_image_url, p.price, p.publish_status " +
            "FROM browse_history bh " +
            "JOIN products p ON p.product_id = bh.product_id " +
            "WHERE bh.user_id = ? " +
            "ORDER BY bh.browse_time DESC LIMIT ? OFFSET ?";

        List<BrowseHistory> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, loginUser.getUserId());
            ps.setInt(2, pageSize);
            ps.setInt(3, offset);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BrowseHistory bh = new BrowseHistory();
                    bh.setId(rs.getLong("id"));
                    bh.setProductId(rs.getLong("product_id"));
                    bh.setBrowseTime(rs.getTimestamp("browse_time"));
                    bh.setProductTitle(rs.getString("title"));
                    bh.setCoverImageUrl(rs.getString("cover_image_url"));
                    bh.setPrice(rs.getBigDecimal("price"));
                    bh.setProductStatus(rs.getString("publish_status"));
                    list.add(bh);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("historyList", list);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalCount", totalCount);
        request.getRequestDispatcher("/my-browse-history.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        User loginUser = session == null ? null : (User) session.getAttribute("loginUser");
        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        if ("clear".equals(action)) {
            String sql = "DELETE FROM browse_history WHERE user_id = ?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setLong(1, loginUser.getUserId());
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.sendRedirect(request.getContextPath() + "/browse-history");
    }
}
