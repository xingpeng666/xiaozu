<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="com.minzu.entity.User" %>
<%
    List<Product> productList = (List<Product>) request.getAttribute("products");
    User loginUser  = (User) session.getAttribute("loginUser");
    String keyword  = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String catId    = request.getAttribute("categoryId") != null ? (String) request.getAttribute("categoryId") : "";
    int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? (int) request.getAttribute("totalPages")  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? (int) request.getAttribute("totalCount")  : 0;

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");

    int unreadNotifyCount = 0;
    if (loginUser != null) {
        try {
            java.sql.Connection nConn = com.minzu.util.DBUtil.getConnection();
            java.sql.PreparedStatement nPs = nConn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE user_id=? AND is_read=0");
            nPs.setInt(1, loginUser.getUserId());
            java.sql.ResultSet nRs = nPs.executeQuery();
            if (nRs.next()) unreadNotifyCount = nRs.getInt(1);
            nRs.close(); nPs.close(); nConn.close();
        } catch (Exception ignore) {}
    }

    int textbookCatId = 0;
    try {
        java.sql.Connection catConn = com.minzu.util.DBUtil.getConnection();
        java.sql.PreparedStatement catPs = catConn.prepareStatement("SELECT category_id FROM categories WHERE category_name LIKE '%教材%' LIMIT 1");
        java.sql.ResultSet catRs = catPs.executeQuery();
        if (catRs.next()) textbookCatId = catRs.getInt("category_id");
        catRs.close(); catPs.close(); catConn.close();
    } catch (Exception ignore) {}
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>浏览商品 — 民大二手交易平台</title>
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
            --price-color:#c2410c;
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
        .nav-brand-name { font-size: 15px; font-weight: 700; }
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

        /* CONTAINER */
        .container { max-width: 1200px; margin: 0 auto; padding: 28px 20px 64px; }

        /* ALERTS */
        .alert {
            padding: 12px 16px; border-radius: 9px;
            font-size: 14px; margin-bottom: 18px;
            display: flex; align-items: center; gap: 8px;
        }
        .alert-success { background: #f0fdf4; border: 1px solid #bbf7d0; color: #15803d; }
        .alert-error   { background: #fff1f0; border: 1px solid #ffc5c5; color: #b91c1c; }

        /* SEARCH BAR */
        .search-bar {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 12px 16px;
            display: flex;
            gap: 10px;
            align-items: center;
            margin-bottom: 14px;
            box-shadow: var(--shadow-sm);
            flex-wrap: wrap;
        }
        .search-input-wrap {
            flex: 1; min-width: 200px;
            position: relative;
            display: flex; align-items: center;
        }
        .search-input-icon {
            position: absolute; left: 11px;
            color: var(--text-faint);
            pointer-events: none;
        }
        .search-bar input[type=text] {
            width: 100%;
            padding: 9px 14px 9px 36px;
            border: 1.5px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-family: var(--font);
            background: var(--bg);
            color: var(--text);
            outline: none;
            transition: border-color 0.18s, box-shadow 0.18s, background 0.18s;
        }
        .search-bar input[type=text]:focus {
            border-color: var(--primary);
            background: #fff;
            box-shadow: 0 0 0 3px rgba(11,110,99,0.1);
        }
        .search-bar input::placeholder { color: #c0c0c0; }
        .btn-search {
            padding: 9px 22px;
            background: var(--primary); color: #fff;
            border: none; border-radius: var(--radius-sm);
            font-size: 14px; font-weight: 600;
            font-family: var(--font);
            transition: background 0.15s;
            display: flex; align-items: center; gap: 6px;
            white-space: nowrap;
        }
        .btn-search:hover { background: var(--primary-h); }
        .btn-reset {
            padding: 9px 14px;
            background: transparent; color: var(--text-muted);
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-family: var(--font);
            transition: border-color 0.15s, color 0.15s;
            white-space: nowrap;
        }
        .btn-reset:hover { border-color: var(--primary); color: var(--primary); }

        /* FILTER ROW */
        .filter-row {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
            gap: 10px;
            flex-wrap: wrap;
        }
        .cat-tags { display: flex; gap: 8px; flex-wrap: wrap; }
        .cat-tag {
            display: inline-flex; align-items: center; gap: 5px;
            padding: 5px 14px;
            border-radius: 99px;
            font-size: 12.5px; font-weight: 600;
            border: 1.5px solid;
            transition: opacity 0.15s;
        }
        .cat-tag:hover { opacity: 0.75; }
        .cat-tag-textbook { background: #fffbeb; color: #b45309; border-color: #fcd34d; }
        .cat-tag-graduation { background: #f0fdf4; color: #15803d; border-color: #86efac; }
        .result-info { font-size: 13px; color: var(--text-muted); white-space: nowrap; }
        .result-info strong { color: var(--text); }

        /* PRODUCT GRID */
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 16px;
        }
        .product-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            transition: box-shadow 0.2s, transform 0.2s, border-color 0.2s;
            display: flex; flex-direction: column;
        }
        .product-card:hover {
            box-shadow: var(--shadow);
            transform: translateY(-3px);
            border-color: transparent;
        }
        .product-img {
            width: 100%; aspect-ratio: 4/3;
            object-fit: cover;
            background: #f3f4f6;
        }
        .no-img {
            width: 100%; aspect-ratio: 4/3;
            background: #f3f4f6;
            display: flex; flex-direction: column;
            align-items: center; justify-content: center;
            color: var(--text-faint);
            font-size: 13px; gap: 10px;
        }
        .no-img-icon { color: #d1d5db; }
        .card-body { padding: 15px; flex: 1; display: flex; flex-direction: column; }
        .product-title {
            font-size: 14px; font-weight: 600; color: var(--text);
            line-height: 1.45; margin-bottom: 10px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .price-row { display: flex; align-items: baseline; gap: 3px; margin-bottom: 10px; }
        .price-symbol { font-size: 13px; color: var(--price-color); font-weight: 700; }
        .price-num { font-size: 21px; font-weight: 700; color: var(--price-color); line-height: 1; }
        .meta-grid {
            display: grid; grid-template-columns: 1fr 1fr;
            gap: 4px 8px; margin-bottom: 14px;
        }
        .meta-item {
            font-size: 12px; color: var(--text-muted);
            display: flex; align-items: center; gap: 4px;
        }
        .meta-dot { width: 3px; height: 3px; border-radius: 50%; background: var(--text-faint); flex-shrink: 0; }
        .card-footer {
            margin-top: auto;
            display: flex; align-items: center;
            justify-content: space-between;
            padding-top: 12px;
            border-top: 1px solid var(--border);
        }
        .btn-detail {
            font-size: 13px; font-weight: 600;
            color: var(--primary);
            padding: 7px 14px;
            border-radius: 7px;
            background: var(--primary-hl);
            transition: background 0.15s;
        }
        .btn-detail:hover { background: #b5dad6; }
        .btn-delete {
            font-size: 12px; color: #dc2626;
            background: #fff1f1;
            border: 1px solid #fecaca;
            padding: 6px 11px;
            border-radius: 7px;
            font-family: var(--font);
            transition: background 0.15s;
        }
        .btn-delete:hover { background: #fee2e2; }

        /* EMPTY STATE */
        .empty-state {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 72px 24px;
            text-align: center;
            color: var(--text-muted);
        }
        .empty-icon { margin: 0 auto 16px; color: #d1d5db; }
        .empty-title { font-size: 16px; font-weight: 600; color: var(--text); margin-bottom: 6px; }
        .empty-desc { font-size: 14px; }

        /* PAGINATION */
        .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 6px;
            margin-top: 40px;
            flex-wrap: wrap;
        }
        .page-btn {
            min-width: 36px; height: 36px;
            padding: 0 10px;
            border-radius: 8px;
            border: 1.5px solid var(--border);
            background: var(--surface);
            color: var(--text-muted);
            font-size: 14px; font-weight: 500;
            display: inline-flex; align-items: center; justify-content: center;
            transition: all 0.15s;
            font-family: var(--font);
            cursor: pointer;
        }
        .page-btn:hover { border-color: var(--primary); color: var(--primary); }
        .page-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .page-btn.disabled { pointer-events: none; opacity: 0.35; }
        .page-info { font-size: 12px; color: var(--text-faint); padding: 0 6px; }
        .page-ellipsis { color: var(--text-faint); padding: 0 4px; }

        @media (max-width: 768px) {
            .nav { padding: 0 14px; }
            .nav-links { display: none; }
            .grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 480px) {
            .grid { grid-template-columns: 1fr; }
            .filter-row { flex-direction: column; align-items: flex-start; }
        }
    </style>
</head>
<body>

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
        <li><a href="${pageContext.request.contextPath}/index.jsp">首页</a></li>
        <li><a href="${pageContext.request.contextPath}/pickup-locations.jsp">自提点</a></li>
        <li><a href="${pageContext.request.contextPath}/product-list" class="active">浏览商品</a></li>
        <% if (loginUser != null) { %>
        <li><a href="${pageContext.request.contextPath}/my-products">我的商品</a></li>
        <li><a href="${pageContext.request.contextPath}/orders">我的订单</a></li>
        <li><a href="${pageContext.request.contextPath}/messages">私信</a></li>
        <li><a href="${pageContext.request.contextPath}/my-favorites">收藏</a></li>
        <li>
            <a href="${pageContext.request.contextPath}/notifications" style="position:relative;">
                通知
                <% if (unreadNotifyCount > 0) { %>
                <span class="notif-badge"><%= unreadNotifyCount %></span>
                <% } %>
            </a>
        </li>
        <% } %>
    </ul>
    <div class="nav-right">
        <% if (loginUser != null) { %>
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

<div class="container">

    <% if (successMsg != null) { %>
    <div class="alert alert-success">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
        <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-error">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%= errorMsg %>
    </div>
    <% } %>

    <!-- Search Bar -->
    <form class="search-bar" method="get" action="${pageContext.request.contextPath}/product-list">
        <div class="search-input-wrap">
            <span class="search-input-icon" aria-hidden="true">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
            </span>
            <input type="text" name="keyword" placeholder="搜索商品名称、分类…"
                   value="<%= keyword != null ? keyword : "" %>" aria-label="搜索商品">
        </div>
        <button type="submit" class="btn-search">搜索</button>
        <% if (keyword != null && !keyword.isEmpty()) { %>
        <a href="${pageContext.request.contextPath}/product-list"><button type="button" class="btn-reset">清除筛选</button></a>
        <% } %>
    </form>

    <!-- Filter Row: category tags + result count -->
    <div class="filter-row">
        <div class="cat-tags">
            <% if (textbookCatId > 0) { %>
            <a href="${pageContext.request.contextPath}/product-list?categoryId=<%= textbookCatId %>" class="cat-tag cat-tag-textbook">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/></svg>
                教材专区
            </a>
            <% } %>
            <a href="${pageContext.request.contextPath}/product-list?tag=graduation" class="cat-tag cat-tag-graduation">
                <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M22 10v6M2 10l10-5 10 5-10 5z"/><path d="M6 12v5c3 3 9 3 12 0v-5"/></svg>
                毕业季专区
            </a>
        </div>
        <span class="result-info">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                "<strong><%= keyword %></strong>" 的结果 · 共 <strong><%= totalCount %></strong> 件
            <% } else if ("graduation".equals(request.getParameter("tag"))) { %>
                毕业季专区 · 共 <strong><%= totalCount %></strong> 件
            <% } else { %>
                全部商品 · 共 <strong><%= totalCount %></strong> 件
            <% } %>
        </span>
    </div>

    <!-- Product Grid -->
    <% if (productList != null && !productList.isEmpty()) { %>
    <div class="grid">
    <% for (Product p : productList) {
           boolean canDelete = false;
           if (loginUser != null) {
               boolean isAdmin = "ADMIN".equalsIgnoreCase(loginUser.getRoleCode());
               boolean isOwner = loginUser.getUserId() == p.getSellerId();
               canDelete = isAdmin || isOwner;
           }
    %>
        <div class="product-card">
            <% if (p.getCoverImageUrl() != null && !"".equals(p.getCoverImageUrl())) { %>
                <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" class="product-img" loading="lazy" width="320" height="240">
            <% } else { %>
                <div class="no-img" aria-label="暂无图片">
                    <div class="no-img-icon">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                    </div>
                    <span>暂无图片</span>
                </div>
            <% } %>
            <div class="card-body">
                <div class="product-title"><%= p.getTitle() %></div>
                <div class="price-row">
                    <span class="price-symbol">¥</span>
                    <span class="price-num"><%= p.getPrice() %></span>
                </div>
                <div class="meta-grid">
                    <span class="meta-item"><span class="meta-dot"></span><%= p.getConditionLevel() != null ? p.getConditionLevel() : "成色未填" %></span>
                    <span class="meta-item"><span class="meta-dot"></span><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                    <span class="meta-item" style="grid-column:1/-1"><span class="meta-dot"></span>卖家：<%= p.getSellerName() != null ? p.getSellerName() : "未知" %></span>
                </div>
                <div class="card-footer">
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="btn-detail">查看详情</a>
                    <% if (canDelete) { %>
                    <form action="${pageContext.request.contextPath}/delete-product" method="post" style="margin:0;"
                          onsubmit="return confirm('确定要删除这个商品吗？');">
                        <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                        <button type="submit" class="btn-delete">删除</button>
                    </form>
                    <% } %>
                </div>
            </div>
        </div>
    <% } %>
    </div>

    <!-- Pagination -->
    <% if (totalPages > 1) {
           String kw = (keyword != null && !keyword.isEmpty()) ? "&keyword=" + java.net.URLEncoder.encode(keyword, "UTF-8") : "";
           String ci = (catId != null && !catId.isEmpty()) ? "&categoryId=" + catId : "";
    %>
    <div class="pagination">
        <a href="<%= request.getContextPath() %>/product-list?page=<%= currentPage - 1 %><%= kw %><%= ci %>">
            <button class="page-btn <%= currentPage == 1 ? "disabled" : "" %>" <%= currentPage == 1 ? "disabled" : "" %> aria-label="上一页">&lsaquo;</button>
        </a>

        <% int startP = Math.max(1, currentPage - 2);
           int endP   = Math.min(totalPages, currentPage + 2);
           if (startP > 1) { %>
            <a href="<%= request.getContextPath() %>/product-list?page=1<%= kw %><%= ci %>"><button class="page-btn">1</button></a>
            <% if (startP > 2) { %><span class="page-ellipsis">…</span><% } %>
        <% }
           for (int pp = startP; pp <= endP; pp++) { %>
            <a href="<%= request.getContextPath() %>/product-list?page=<%= pp %><%= kw %><%= ci %>">
                <button class="page-btn <%= pp == currentPage ? "active" : "" %>"><%= pp %></button>
            </a>
        <% }
           if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span class="page-ellipsis">…</span><% } %>
            <a href="<%= request.getContextPath() %>/product-list?page=<%= totalPages %><%= kw %><%= ci %>"><button class="page-btn"><%= totalPages %></button></a>
        <% } %>

        <a href="<%= request.getContextPath() %>/product-list?page=<%= currentPage + 1 %><%= kw %><%= ci %>">
            <button class="page-btn <%= currentPage == totalPages ? "disabled" : "" %>" <%= currentPage == totalPages ? "disabled" : "" %> aria-label="下一页">&rsaquo;</button>
        </a>

        <span class="page-info">第 <%= currentPage %> / <%= totalPages %> 页 · 共 <%= totalCount %> 件</span>
    </div>
    <% } %>

    <% } else { %>
    <!-- Empty State -->
    <div class="empty-state">
        <div class="empty-icon">
            <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
        </div>
        <div class="empty-title">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                没有找到 "<%= keyword %>" 相关商品
            <% } else { %>
                暂时没有商品
            <% } %>
        </div>
        <div class="empty-desc">
            <% if (keyword != null && !keyword.isEmpty()) { %>
                换个关键词试试，或者 <a href="${pageContext.request.contextPath}/product-list" style="color:var(--primary);font-weight:600;">查看全部商品</a>
            <% } else { %>
                快去发布第一件商品吧
            <% } %>
        </div>
    </div>
    <% } %>

</div>

</body>
</html>
