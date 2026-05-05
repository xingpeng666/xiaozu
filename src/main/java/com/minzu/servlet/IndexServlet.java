package com.minzu.servlet;

import com.minzu.entity.Product;
import com.minzu.entity.User;
import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/index")
public class IndexServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = null;
        HttpSession session = request.getSession(false);
        if (session != null) {
            loginUser = (User) session.getAttribute("loginUser");
        }

        if (loginUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 查询最新上架商品（8个）
        List<Product> latestProducts = new ArrayList<>();
        String sql = "SELECT p.product_id, p.title, p.price, p.cover_image_url, p.condition_level, " +
                     "c.category_name, u.real_name AS seller_name " +
                     "FROM products p " +
                     "LEFT JOIN categories c ON p.category_id = c.category_id " +
                     "LEFT JOIN users u ON p.seller_id = u.user_id " +
                     "WHERE p.publish_status = 'ON_SALE' AND p.is_deleted = 0 " +
                     "ORDER BY p.created_at DESC LIMIT 8";

        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery()
        ) {
            while (rs.next()) {
                Product p = new Product();
                p.setProductId(rs.getInt("product_id"));
                p.setTitle(rs.getString("title"));
                p.setPrice(rs.getBigDecimal("price"));
                p.setCoverImageUrl(rs.getString("cover_image_url"));
                p.setConditionLevel(rs.getString("condition_level"));
                p.setCategoryName(rs.getString("category_name"));
                p.setSellerName(rs.getString("seller_name"));
                latestProducts.add(p);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("latestProducts", latestProducts);
        request.setAttribute("loginUser", loginUser);
        request.getRequestDispatcher("/index.jsp").forward(request, response);
    }
}
