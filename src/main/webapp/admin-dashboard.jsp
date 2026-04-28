<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%
    // 权限校验
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

    long totalUsers      = request.getAttribute("totalUsers")      != null ? ((Number) request.getAttribute("totalUsers")).longValue()      : 0;
    long todayNewUsers   = request.getAttribute("todayNewUsers")   != null ? ((Number) request.getAttribute("todayNewUsers")).longValue()   : 0;
    long onSaleProducts  = request.getAttribute("onSaleProducts")  != null ? ((Number) request.getAttribute("onSaleProducts")).longValue()  : 0;
    long pendingProducts = request.getAttribute("pendingProducts") != null ? ((Number) request.getAttribute("pendingProducts")).longValue() : 0;
    long totalOrders     = request.getAttribute("totalOrders")     != null ? ((Number) request.getAttribute("totalOrders")).longValue()     : 0;
    long completedOrders = request.getAttribute("completedOrders") != null ? ((Number) request.getAttribute("completedOrders")).longValue() : 0;
    BigDecimal totalAmount = request.getAttribute("totalAmount")   != null ? (BigDecimal) request.getAttribute("totalAmount")              : BigDecimal.ZERO;
    List<Map<String, Object>> dailyOrders = (List<Map<String, Object>>) request.getAttribute("dailyOrders");
    if (dailyOrders == null) dailyOrders = new ArrayList<>();

    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理统计面板 - 民大二手交易平台</title>
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
        .stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 28px; }
        .stat-card { background: #fff; border-radius: 14px; padding: 22px 20px; box-shadow: 0 4px 18px rgba(0,0,0,0.06); }
        .stat-card .stat-label { font-size: 13px; color: #888; margin-bottom: 8px; }
        .stat-card .stat-value { font-size: 30px; font-weight: bold; }
        .stat-card .stat-sub  { font-size: 12px; color: #999; margin-top: 6px; }
        .stat-blue  .stat-value { color: #1677ff; }
        .stat-green  .stat-value { color: #52c41a; }
        .stat-orange .stat-value { color: #fa8c16; }
        .stat-red    .stat-value { color: #ff4d4f; }
        .stat-purple .stat-value { color: #722ed1; }
        .table-card { background: #fff; border-radius: 14px; padding: 24px; box-shadow: 0 4px 18px rgba(0,0,0,0.06); }
        .table-card h3 { margin: 0 0 16px; font-size: 18px; color: #1f1f1f; }
        table { width: 100%; border-collapse: collapse; }
        th, td { padding: 12px 16px; text-align: left; border-bottom: 1px solid #f0f0f0; font-size: 14px; }
        th { background: #fafafa; font-weight: bold; color: #555; }
        tr:hover td { background: #fafcff; }
        .quick-links { display: flex; gap: 12px; flex-wrap: wrap; margin-top: 22px; }
        .quick-links a { display: inline-block; padding: 10px 20px; border-radius: 8px; text-decoration: none; font-size: 14px; transition: all 0.2s; background: #1677ff; color: #fff; }
        .quick-links a:hover { background: #0e5fd8; }
        .quick-links a.btn-purple { background: #722ed1; }
        .quick-links a.btn-purple:hover { background: #531dab; }
        @media (max-width: 900px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 500px) { .stats-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台 - 管理后台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard">统计面板</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-title">&#128202; 数据统计面板</div>

    <% if (successMsg != null) { %>
        <div class="msg msg-success">&#9989; <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">&#10060; <%= errorMsg %></div>
    <% } %>

    <!-- 统计卡片 -->
    <div class="stats-grid">
        <div class="stat-card stat-blue">
            <div class="stat-label">&#128101; 平台总用户数</div>
            <div class="stat-value"><%= totalUsers %></div>
            <div class="stat-sub">今日新增 <%= todayNewUsers %> 人</div>
        </div>
        <div class="stat-card stat-green">
            <div class="stat-label">&#128230; 在售商品数</div>
            <div class="stat-value"><%= onSaleProducts %></div>
        </div>
        <div class="stat-card stat-orange">
            <div class="stat-label">&#128221; 待审核商品</div>
            <div class="stat-value"><%= pendingProducts %></div>
        </div>
        <div class="stat-card stat-purple">
            <div class="stat-label">&#128179; 总交易金额</div>
            <div class="stat-value">&yen;<%= String.format("%.2f", totalAmount) %></div>
            <div class="stat-sub"><%= totalOrders %> 笔订单，已完成 <%= completedOrders %> 笔</div>
        </div>
    </div>

    <!-- 近7天订单趋势 -->
    <div class="table-card">
        <h3>&#128200; 近 7 天订单趋势</h3>
        <table>
            <thead>
                <tr>
                    <th>日期</th>
                    <th>订单数</th>
                </tr>
            </thead>
            <tbody>
                <% if (dailyOrders.isEmpty()) { %>
                    <tr><td colspan="2" style="text-align:center;color:#999;">暂无数据</td></tr>
                <% } else {
                    for (Map<String, Object> row : dailyOrders) { %>
                    <tr>
                        <td><%= row.get("orderDate") %></td>
                        <td><strong><%= row.get("orderCount") %></strong> 笔</td>
                    </tr>
                <%  } } %>
            </tbody>
        </table>
    </div>

    <!-- 快捷操作 -->
    <div class="quick-links">
        <a href="${pageContext.request.contextPath}/admin/users">&#128100; 用户审核管理</a>
        <a href="${pageContext.request.contextPath}/admin/products">&#128269; 商品审核管理</a>
        <a class="btn-purple" href="${pageContext.request.contextPath}/admin/reports">&#128276; 举报管理（待实现）</a>
    </div>
</div>

</body>
</html>
