<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    // 权限校验
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

    List<Map<String, Object>> reportList = (List<Map<String, Object>>) request.getAttribute("reportList");
    if (reportList == null) reportList = new ArrayList<>();

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) { request.setAttribute("errorMsg", errorMsg); session.removeAttribute("errorMsg"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>举报管理 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header { height: 56px; background: #1677ff; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18); }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a { color: #fff; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 1200px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 20px; }
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 14px; overflow: hidden; box-shadow: 0 4px 18px rgba(0,0,0,0.06); }
        th, td { padding: 14px 16px; text-align: left; border-bottom: 1px solid #f0f0f0; font-size: 14px; }
        th { background: #fafafa; font-weight: bold; color: #555; white-space: nowrap; }
        tr:hover td { background: #fafcff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: 12px; color: #fff; }
        .badge-pending { background: #fa8c16; }
        .badge-handled { background: #8c8c8c; }
        .btn { padding: 8px 16px; border-radius: 8px; font-size: 13px; border: none; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-sm { padding: 6px 14px; font-size: 12px; }
        .btn-danger { background: #fff1f0; color: #cf1322; border: 1px solid #ffccc7; }
        .btn-danger:hover { background: #ffe7e6; }
        .btn-gray { background: #f5f5f5; color: #555; border: 1px solid #ddd; }
        .btn-gray:hover { border-color: #1677ff; color: #1677ff; }
        .empty { background: #fff; border-radius: 14px; padding: 60px 20px; text-align: center; color: #999; box-shadow: 0 4px 18px rgba(0,0,0,0.05); }
        @media (max-width: 768px) { th, td { padding: 10px 12px; font-size: 12px; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台 - 管理后台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard">统计面板</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/report">举报管理</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-title">&#128276; 举报管理</div>

    <% if (successMsg != null) { %>
        <div class="msg msg-success">&#9989; <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">&#10060; <%= errorMsg %></div>
    <% } %>

    <% if (reportList.isEmpty()) { %>
        <div class="empty">暂无举报记录</div>
    <% } else { %>
        <table>
            <thead>
                <tr>
                    <th>举报ID</th>
                    <th>举报人</th>
                    <th>商品</th>
                    <th>商品状态</th>
                    <th>举报原因</th>
                    <th>状态</th>
                    <th>举报时间</th>
                    <th>操作</th>
                </tr>
            </thead>
            <tbody>
                <% for (Map<String, Object> r : reportList) { %>
                <tr>
                    <td>#<%= r.get("reportId") %></td>
                    <td><%= r.get("reporterName") != null ? r.get("reporterName") : "未知" %></td>
                    <td>
                        <a href="${pageContext.request.contextPath}/product-detail?id=<%= r.get("productId") %>" target="_blank">
                            <%= r.get("productTitle") != null ? r.get("productTitle") : "商品已删除" %>
                        </a>
                    </td>
                    <td><%= r.get("publishStatus") != null ? r.get("publishStatus") : "-" %></td>
                    <td><%= r.get("reason") %></td>
                    <td>
                        <% String st = (String) r.get("status"); %>
                        <span class="badge <%= "PENDING".equals(st) ? "badge-pending" : "badge-handled" %>">
                            <%= "PENDING".equals(st) ? "待处理" : "已处理" %>
                        </span>
                    </td>
                    <td><%= r.get("createdAt") %></td>
                    <td>
                        <% if ("PENDING".equals(r.get("status")) && !"OFF_SHELF".equals(r.get("publishStatus")) && !"SOLD".equals(r.get("publishStatus"))) { %>
                            <form action="${pageContext.request.contextPath}/report" method="post" style="margin:0;display:inline;"
                                  onsubmit="return confirm('确定要下架该商品吗？该操作不可撤销。');">
                                <input type="hidden" name="action" value="takedown">
                                <input type="hidden" name="productId" value="<%= r.get("productId") %>">
                                <input type="hidden" name="reportId" value="<%= r.get("reportId") %>">
                                <button type="submit" class="btn btn-danger btn-sm">下架商品</button>
                            </form>
                        <% } else if ("OFF_SHELF".equals(r.get("publishStatus"))) { %>
                            <span style="color:#999;font-size:12px;">已下架</span>
                        <% } else if ("SOLD".equals(r.get("publishStatus"))) { %>
                            <span style="color:#999;font-size:12px;">已售出</span>
                        <% } else { %>
                            <span style="color:#999;font-size:12px;">-</span>
                        <% } %>
                    </td>
                </tr>
                <% } %>
            </tbody>
        </table>
    <% } %>
</div>

</body>
</html>
