<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%
    User navLoginUser = (User) session.getAttribute("loginUser");
    String activePage = request.getParameter("active");
    if (activePage == null) activePage = "";

    int navUnreadNotifyCount = 0;
    if (navLoginUser != null) {
        try {
            java.sql.Connection navConn = com.minzu.util.DBUtil.getConnection();
            java.sql.PreparedStatement navPs = navConn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0");
            navPs.setInt(1, navLoginUser.getUserId());
            java.sql.ResultSet navRs = navPs.executeQuery();
            if (navRs.next()) navUnreadNotifyCount = navRs.getInt(1);
            navRs.close(); navPs.close(); navConn.close();
        } catch (Exception ignore) {}
    }
%>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
    :root {
        --bg:         #f4f3ef;
        --surface:    #ffffff;
        --border:     rgba(0,0,0,0.08);
        --text:       #1a1a1a;
        --text-muted: #737373;
        --text-faint: #b0b0b0;
        --primary:    #0b6e63;
        --primary-h:  #085c52;
        --primary-hl: #d0eae7;
        --radius-sm:  8px;
        --radius:     14px;
        --shadow-sm:  0 2px 8px rgba(0,0,0,0.05);
        --shadow:     0 8px 28px rgba(0,0,0,0.08);
        --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
        --nav-h:      60px;
    }
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    html { -webkit-font-smoothing: antialiased; }
    body { font-family: var(--font); background: var(--bg); color: var(--text); font-size: 15px; line-height: 1.6; min-height: 100dvh; }
    a { text-decoration: none; color: inherit; }
    button { cursor: pointer; font-family: var(--font); }
    img { display: block; max-width: 100%; }

    /* NAV */
    .nav {
        height: var(--nav-h);
        background: var(--surface);
        border-bottom: 1px solid var(--border);
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 28px;
        position: sticky; top: 0; z-index: 100;
    }
    .nav-brand { display: flex; align-items: center; gap: 9px; }
    .nav-logo {
        width: 34px; height: 34px;
        background: var(--primary);
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        color: #fff; flex-shrink: 0;
    }
    .nav-brand-name { font-size: 15px; font-weight: 700; color: var(--text); }
    .nav-links { display: flex; align-items: center; gap: 2px; list-style: none; }
    .nav-links a {
        font-size: 14px; font-weight: 500; color: var(--text-muted);
        padding: 7px 12px; border-radius: 7px;
        transition: color 0.15s, background 0.15s;
        display: flex; align-items: center; gap: 5px; position: relative;
    }
    .nav-links a:hover { color: var(--text); background: var(--bg); }
    .nav-links a.active { color: var(--primary); background: var(--primary-hl); }
    .notif-badge {
        position: absolute; top: 2px; right: 2px;
        background: #ef4444; color: #fff;
        border-radius: 10px; font-size: 9px; line-height: 1;
        padding: 2px 4px; font-weight: 700; min-width: 14px; text-align: center;
    }
    .nav-right { display: flex; align-items: center; gap: 10px; }
    .logout-link {
        font-size: 13px; color: var(--text-muted);
        padding: 7px 10px; border-radius: 7px;
        transition: color 0.15s, background 0.15s;
    }
    .logout-link:hover { color: #ef4444; background: #fff1f1; }
    .btn-publish-nav {
        padding: 8px 16px;
        background: var(--primary); color: #fff;
        border: none; border-radius: 7px;
        font-size: 13px; font-weight: 600;
        font-family: var(--font);
        transition: background 0.15s;
        display: flex; align-items: center; gap: 5px;
    }
    .btn-publish-nav:hover { background: var(--primary-h); }

    @media (max-width: 768px) {
        .nav { padding: 0 14px; }
        .nav-links { display: none; }
    }
</style>

<nav class="nav">
    <div class="nav-brand">
        <div class="nav-logo" aria-hidden="true">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
        </div>
        <span class="nav-brand-name">民大二手平台</span>
    </div>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/index.jsp" class="<%= "home".equals(activePage) ? "active" : "" %>">首页</a></li>
        <li><a href="${pageContext.request.contextPath}/pickup-locations.jsp" class="<%= "pickup".equals(activePage) ? "active" : "" %>">自提点</a></li>
        <li><a href="${pageContext.request.contextPath}/product-list" class="<%= "products".equals(activePage) ? "active" : "" %>">浏览商品</a></li>
        <% if (navLoginUser != null) { %>
        <li><a href="${pageContext.request.contextPath}/my-products" class="<%= "my-products".equals(activePage) ? "active" : "" %>">我的商品</a></li>
        <li><a href="${pageContext.request.contextPath}/orders" class="<%= "orders".equals(activePage) ? "active" : "" %>">我的订单</a></li>
        <li><a href="${pageContext.request.contextPath}/messages" class="<%= "messages".equals(activePage) ? "active" : "" %>">私信</a></li>
        <li><a href="${pageContext.request.contextPath}/my-favorites" class="<%= "favorites".equals(activePage) ? "active" : "" %>">收藏</a></li>
        <li>
            <a href="${pageContext.request.contextPath}/notifications" class="<%= "notifications".equals(activePage) ? "active" : "" %>" style="position:relative;">
                通知
                <% if (navUnreadNotifyCount > 0) { %>
                <span class="notif-badge"><%= navUnreadNotifyCount %></span>
                <% } %>
            </a>
        </li>
        <% } %>
    </ul>
    <div class="nav-right">
        <% if (navLoginUser != null) { %>
            <a href="${pageContext.request.contextPath}/publish-product">
                <button class="btn-publish-nav">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    发布商品
                </button>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="logout-link">退出</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login" class="logout-link">登录</a>
        <% } %>
    </div>
</nav>
