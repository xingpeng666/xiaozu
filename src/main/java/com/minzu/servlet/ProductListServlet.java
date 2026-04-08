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
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@WebServlet("/product-list")
public class ProductListServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User loginUser = null;
        HttpSession session = request.getSession(false);
        if (session != null) {
            loginUser = (User) session.getAttribute("loginUser");
        }

        String keyword     = request.getParameter("keyword");
        String categoryIdStr = request.getParameter("categoryId");
        String categoryName = request.getParameter("category");
        String tag          = request.getParameter("tag");
        String sort         = request.getParameter("sort");
        String minPriceStr  = request.getParameter("minPrice");
        String maxPriceStr  = request.getParameter("maxPrice");

        // 分页
        int page = 1;
        try {
            String pageStr = request.getParameter("page");
            if (pageStr != null) page = Math.max(1, Integer.parseInt(pageStr.trim()));
        } catch (NumberFormatException ignored) {}

        // 拼装 WHERE 条件
        StringBuilder where = new StringBuilder("WHERE p.publish_status = 'ON_SALE' AND p.is_deleted = 0");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" AND (p.title LIKE ? OR p.product_desc LIKE ?)");
            params.add("%" + keyword.trim() + "%");
            params.add("%" + keyword.trim() + "%");
        }
        if (categoryIdStr != null && !categoryIdStr.trim().isEmpty()) {
            try {
                int categoryId = Integer.parseInt(categoryIdStr.trim());
                where.append(" AND p.category_id = ?");
                params.add(categoryId);
            } catch (NumberFormatException ignored) {
                categoryIdStr = null;
            }
        } else if (categoryName != null && !categoryName.trim().isEmpty()) {
            where.append(" AND c.category_name = ?");
            params.add(categoryName.trim());
        }
        if (tag != null && !tag.trim().isEmpty()) {
            where.append(" AND p.tags LIKE ?");
            params.add("%" + tag.trim() + "%");
        }
        // 价格区间筛选
        if (minPriceStr != null && !minPriceStr.trim().isEmpty()) {
            try {
                double minPrice = Double.parseDouble(minPriceStr.trim());
                where.append(" AND p.price >= ?");
                params.add(minPrice);
            } catch (NumberFormatException ignored) {}
        }
        if (maxPriceStr != null && !maxPriceStr.trim().isEmpty()) {
            try {
                double maxPrice = Double.parseDouble(maxPriceStr.trim());
                where.append(" AND p.price <= ?");
                params.add(maxPrice);
            } catch (NumberFormatException ignored) {}
        }

        // 排序条件
        String orderBy = " ORDER BY p.created_at DESC";
        if (sort != null && !sort.trim().isEmpty()) {
            switch (sort.trim()) {
                case "price_asc":
                    orderBy = " ORDER BY p.price ASC";
                    break;
                case "price_desc":
                    orderBy = " ORDER BY p.price DESC";
                    break;
                case "views":
                    orderBy = " ORDER BY p.view_count DESC";
                    break;
                case "newest":
                default:
                    orderBy = " ORDER BY p.created_at DESC";
                    break;
            }
        }

        // 总数查询
        String countSql = "SELECT COUNT(*) FROM products p " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " + where;
        int totalCount = 0;
        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(countSql)
        ) {
            for (int i = 0; i < params.size(); i++) ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) totalCount = rs.getInt(1);
            }
        } catch (Exception e) { e.printStackTrace(); }

        int totalPages = (int) Math.ceil((double) totalCount / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (page > totalPages) page = totalPages;
        int offset = (page - 1) * PAGE_SIZE;

        String sql = "SELECT p.product_id, p.seller_id, u.real_name AS seller_name, " +
                "p.category_id, c.category_name, p.title, p.product_desc, " +
                "p.price, p.condition_level, p.publish_status, p.cover_image_url, p.created_at " +
                "FROM products p " +
                "LEFT JOIN users u ON p.seller_id = u.user_id " +
                "LEFT JOIN categories c ON p.category_id = c.category_id " +
                where + orderBy + " LIMIT ? OFFSET ?";

        List<Product> products = new ArrayList<>();

        try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)
        ) {
            int idx = 1;
            for (Object p : params) ps.setObject(idx++, p);
            ps.setInt(idx++, PAGE_SIZE);
            ps.setInt(idx,   offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Product p = new Product();
                    p.setProductId(rs.getInt("product_id"));
                    p.setSellerId(rs.getInt("seller_id"));
                    p.setSellerName(rs.getString("seller_name"));
                    p.setCategoryId(rs.getInt("category_id"));
                    p.setCategoryName(rs.getString("category_name"));
                    p.setTitle(rs.getString("title"));
                    p.setDescription(rs.getString("product_desc"));
                    p.setPrice(rs.getBigDecimal("price"));
                    p.setConditionLevel(rs.getString("condition_level"));
                    p.setProductStatus(rs.getString("publish_status"));
                    p.setCoverImageUrl(rs.getString("cover_image_url"));
                    p.setCreatedAt(rs.getTimestamp("created_at"));
                    products.add(p);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "获取商品列表失败：" + e.getMessage());
        }

        // 查询所有分类
        List<Map<String, Object>> categories = new ArrayList<>();
        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT category_id, category_name FROM categories ORDER BY category_id"
            )
        ) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> cat = new HashMap<>();
                    cat.put("categoryId", rs.getInt("category_id"));
                    cat.put("categoryName", rs.getString("category_name"));
                    categories.add(cat);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("categories", categories);

        // 热门标签统计：从在售商品的 tags 列拆分统计频次，取 TOP 15
        List<Map<String, Object>> hotTags = new ArrayList<>();
        try (
            Connection conn = DBUtil.getConnection();
            PreparedStatement ps = conn.prepareStatement(
                "SELECT tags FROM products WHERE publish_status = 'ON_SALE' AND IFNULL(is_deleted,0) = 0 AND tags IS NOT NULL AND tags != ''"
            )
        ) {
            Map<String, Integer> tagCount = new HashMap<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String tagsStr = rs.getString("tags");
                    for (String t : tagsStr.split(",")) {
                        String trimmed = t.trim();
                        if (!trimmed.isEmpty()) {
                            tagCount.put(trimmed, tagCount.getOrDefault(trimmed, 0) + 1);
                        }
                    }
                }
            }
            // 按频次降序，取 TOP 15
            tagCount.entrySet().stream()
                .sorted((a, b) -> b.getValue() - a.getValue())
                .limit(15)
                .forEach(e -> {
                    Map<String, Object> m = new HashMap<>();
                    m.put("tagName", e.getKey());
                    m.put("count", e.getValue());
                    hotTags.add(m);
                });
        } catch (Exception e) { e.printStackTrace(); }
        request.setAttribute("hotTags", hotTags);

        // 查询当前用户已收藏的 product_id 集合
        Set<Integer> favoriteProductIds = new HashSet<>();
        if (loginUser != null) {
            try (
                Connection conn = DBUtil.getConnection();
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT product_id FROM favorites WHERE user_id = ?"
                )
            ) {
                ps.setInt(1, loginUser.getUserId());
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        favoriteProductIds.add(rs.getInt("product_id"));
                    }
                }
            } catch (Exception e) { e.printStackTrace(); }
        }
        request.setAttribute("favoriteProductIds", favoriteProductIds);

        request.setAttribute("products",    products);
        request.setAttribute("loginUser",   loginUser);
        request.setAttribute("keyword",     keyword);
        request.setAttribute("categoryId",  categoryIdStr);
        request.setAttribute("categoryName", categoryName);
        request.setAttribute("sort",        sort);
        request.setAttribute("minPrice",    minPriceStr);
        request.setAttribute("maxPrice",    maxPriceStr);
        request.setAttribute("currentPage", page);
        request.setAttribute("totalPages",  totalPages);
        request.setAttribute("totalCount",  totalCount);
        request.setAttribute("tag",         tag);
        request.getRequestDispatcher("/product-list.jsp").forward(request, response);
    }
}
