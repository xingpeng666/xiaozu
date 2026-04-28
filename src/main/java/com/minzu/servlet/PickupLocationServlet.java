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
 *   GET  -> 查询所有启用的取货点，渲染 pickup-locations.jsp
 */
@WebServlet("/pickup-locations")
public class PickupLocationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        List<Map<String, Object>> locationList = new ArrayList<>();

        String sql = "SELECT location_id, name, address, description " +
                     "FROM pickup_locations " +
                     "WHERE is_active = 1 " +
                     "ORDER BY location_id";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Map<String, Object> loc = new LinkedHashMap<>();
                loc.put("id", rs.getInt("location_id"));
                loc.put("name", rs.getString("name"));
                loc.put("address", rs.getString("address"));
                loc.put("description", rs.getString("description"));
                locationList.add(loc);
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMsg", "加载取货点列表失败：" + e.getMessage());
        }

        request.setAttribute("locationList", locationList);
        request.getRequestDispatcher("/pickup-locations.jsp").forward(request, response);
    }
}
