package com.minzu.servlet;

import com.minzu.util.DBUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * /pickup-locations
 *   GET  -> 查询所有启用的自提点，渲染 pickup-locations.jsp
 */
@WebServlet("/pickup-locations")
public class PickupLocationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        List<Map<String, Object>> pointList = new ArrayList<>();

        String sql = "SELECT pickup_point_id, point_name, campus_area, address_detail, " +
                     "contact_phone, open_time_desc " +
                     "FROM pickup_points " +
                     "WHERE is_enabled = 1 " +
                     "ORDER BY pickup_point_id";

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
                pointList.add(point);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载自提点列表失败：" + e.getMessage());
        }

        request.setAttribute("locationList", pointList);
        request.getRequestDispatcher("/pickup-locations.jsp").forward(request, response);
    }
}
