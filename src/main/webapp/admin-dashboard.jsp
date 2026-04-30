<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    long totalUsers      = request.getAttribute("totalUsers")      != null ? ((Number) request.getAttribute("totalUsers")).longValue()      : 0;
    long todayNewUsers   = request.getAttribute("todayNewUsers")   != null ? ((Number) request.getAttribute("todayNewUsers")).longValue()   : 0;
    long onSaleProducts  = request.getAttribute("onSaleProducts")  != null ? ((Number) request.getAttribute("onSaleProducts")).longValue()  : 0;
    long pendingProducts = request.getAttribute("pendingProducts") != null ? ((Number) request.getAttribute("pendingProducts")).longValue() : 0;
    long totalOrders     = request.getAttribute("totalOrders")     != null ? ((Number) request.getAttribute("totalOrders")).longValue()     : 0;
    long completedOrders = request.getAttribute("completedOrders") != null ? ((Number) request.getAttribute("completedOrders")).longValue() : 0;
    BigDecimal totalAmount = request.getAttribute("totalAmount") != null ? (BigDecimal) request.getAttribute("totalAmount") : BigDecimal.ZERO;
    List<Map<String, Object>> dailyOrders = (List<Map<String, Object>>) request.getAttribute("dailyOrders");
    if (dailyOrders == null) dailyOrders = new ArrayList<>();
    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理统计面板 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
            --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
            --success-bg:#f0fdf4;--success-bd:#bbf7d0;--success-tx:#15803d;
            --error-bg:#fff1f0;--error-bd:#ffc5c5;--error-tx:#b91c1c;
            --radius:12px;--font:'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --shadow:0 2px 12px rgba(0,0,0,0.06);
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{-webkit-font-smoothing:antialiased}
        body{font-family:var(--font);background:var(--bg);color:var(--text);min-height:100dvh}
        .nav{height:56px;background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 28px;position:sticky;top:0;z-index:100}
        .nav-brand{display:flex;align-items:center;gap:9px;font-size:16px;font-weight:700;color:var(--primary);text-decoration:none}
        .nav-links{display:flex;align-items:center;gap:4px}
        .nav-links a{font-size:13.5px;font-weight:500;color:var(--muted);text-decoration:none;padding:6px 11px;border-radius:7px;transition:background .15s,color .15s}
        .nav-links a:hover{background:var(--primary-hl);color:var(--primary)}
        .nav-links a.active{background:var(--primary-hl);color:var(--primary)}
        .nav-links .btn-logout{margin-left:6px;padding:6px 14px;background:var(--primary);color:#fff;border-radius:7px}
        .nav-links .btn-logout:hover{background:var(--primary-h);color:#fff}
        .container{max-width:1200px;margin:36px auto;padding:0 16px 48px}
        .page-header{margin-bottom:24px}
        .page-header h1{font-size:22px;font-weight:700}
        .alert{padding:11px 14px;border-radius:8px;font-size:13.5px;margin-bottom:18px}
        .alert-success{background:var(--success-bg);border:1px solid var(--success-bd);color:var(--success-tx)}
        .alert-error{background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
        .stats-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:28px}
        .stat-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:20px 18px;box-shadow:var(--shadow)}
        .stat-label{font-size:12.5px;color:var(--muted);margin-bottom:8px}
        .stat-value{font-size:28px;font-weight:700;color:var(--primary)}
        .stat-sub{font-size:12px;color:var(--muted);margin-top:5px}
        .stat-card.c2 .stat-value{color:#059669}
        .stat-card.c3 .stat-value{color:#d97706}
        .stat-card.c4 .stat-value{color:#7c3aed}
        .table-card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);padding:22px 24px;box-shadow:var(--shadow);margin-bottom:22px}
        .table-card h3{font-size:16px;font-weight:700;margin-bottom:16px}
        table{width:100%;border-collapse:collapse}
        th,td{padding:12px 14px;text-align:left;border-bottom:1px solid var(--border);font-size:13.5px}
        th{background:#fafaf9;font-weight:600;color:var(--muted)}
        tr:last-child td{border-bottom:none}
        tr:hover td{background:#f9f9f7}
        .quick-links{display:flex;gap:10px;flex-wrap:wrap;margin-top:6px}
        .quick-links a{display:inline-block;padding:9px 18px;border-radius:8px;text-decoration:none;font-size:13.5px;font-weight:600;background:var(--primary);color:#fff;transition:background .15s}
        .quick-links a:hover{background:var(--primary-h)}
        .quick-links a.sec{background:var(--primary-hl);color:var(--primary)}
        .quick-links a.sec:hover{background:#b8e0db}
        @media(max-width:900px){.stats-grid{grid-template-columns:repeat(2,1fr)}}
        @media(max-width:500px){.stats-grid{grid-template-columns:1fr}}
    </style>
</head>
<body>
<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        民大二手 · 管理后台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/admin/dashboard" class="active">统计面板</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>
<div class="container">
    <div class="page-header"><h1>📊 数据统计面板</h1></div>
    <% if (successMsg != null) { %><div class="alert alert-success">✓ <%= successMsg %></div><% } %>
    <% if (errorMsg != null) { %><div class="alert alert-error">✕ <%= errorMsg %></div><% } %>

    <div class="stats-grid">
        <div class="stat-card">
            <div class="stat-label">👥 平台总用户数</div>
            <div class="stat-value"><%= totalUsers %></div>
            <div class="stat-sub">今日新增 <%= todayNewUsers %> 人</div>
        </div>
        <div class="stat-card c2">
            <div class="stat-label">📦 在售商品数</div>
            <div class="stat-value"><%= onSaleProducts %></div>
        </div>
        <div class="stat-card c3">
            <div class="stat-label">📝 待审核商品</div>
            <div class="stat-value"><%= pendingProducts %></div>
        </div>
        <div class="stat-card c4">
            <div class="stat-label">💰 总交易金额</div>
            <div class="stat-value">&yen;<%= String.format("%.2f", totalAmount) %></div>
            <div class="stat-sub"><%= totalOrders %> 笔订单，已完成 <%= completedOrders %> 笔</div>
        </div>
    </div>

    <div class="table-card">
        <h3>📈 近 7 天订单趋势</h3>
        <table>
            <thead><tr><th>日期</th><th>订单数</th></tr></thead>
            <tbody>
                <% if (dailyOrders.isEmpty()) { %>
                <tr><td colspan="2" style="text-align:center;color:var(--muted);">暂无数据</td></tr>
                <% } else { for (Map<String, Object> row : dailyOrders) { %>
                <tr>
                    <td><%= row.get("orderDate") %></td>
                    <td><strong><%= row.get("orderCount") %></strong> 笔</td>
                </tr>
                <% } } %>
            </tbody>
        </table>
    </div>

    <div class="quick-links">
        <a href="${pageContext.request.contextPath}/admin/users">👤 用户审核管理</a>
        <a href="${pageContext.request.contextPath}/admin/products">🔍 商品审核管理</a>
        <a class="sec" href="${pageContext.request.contextPath}/admin/reports">🔔 举报管理</a>
    </div>
</div>
</body>
</html>
