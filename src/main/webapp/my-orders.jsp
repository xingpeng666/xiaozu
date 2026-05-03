<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    List<Map<String, Object>> orderList = (List<Map<String, Object>>) request.getAttribute("orderList");
    if (orderList == null) orderList = new ArrayList<>();
    String type = (String) request.getAttribute("type");
    if (type == null) type = "buy";
    int currentPage = request.getAttribute("currentPage") != null ? ((Number) request.getAttribute("currentPage")).intValue() : 1;
    int totalPages  = request.getAttribute("totalPages")  != null ? ((Number) request.getAttribute("totalPages")).intValue()  : 1;
    int totalCount  = request.getAttribute("totalCount")  != null ? ((Number) request.getAttribute("totalCount")).intValue()  : 0;
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
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
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的订单 - 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300..700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --color-bg: #f7f6f2;
            --color-surface: #ffffff;
            --color-surface-2: #f9f8f5;
            --color-border: oklch(0.2 0.01 80 / 0.12);
            --color-divider: #e8e6e1;
            --color-text: #28251d;
            --color-text-muted: #7a7974;
            --color-text-faint: #bab9b4;
            --color-primary: #01696f;
            --color-primary-hover: #0c4e54;
            --color-primary-bg: #e6f4f4;
            --color-error: #a12c7b;
            --color-error-bg: #f9eef5;
            --color-error-border: #e0ced7;
            --color-warning: #964219;
            --color-warning-bg: #fdf3ec;
            --color-warning-border: #f5d5be;
            --color-success: #437a22;
            --color-success-bg: #edf5e7;
            --color-success-border: #c4dbb4;
            --color-neutral-bg: #f0efeb;
            --color-neutral-text: #5a5955;
            --radius-sm: 6px;
            --radius-md: 8px;
            --radius-lg: 12px;
            --radius-xl: 16px;
            --radius-full: 9999px;
            --shadow-sm: 0 1px 2px oklch(0.2 0.01 80 / 0.06);
            --shadow-md: 0 4px 12px oklch(0.2 0.01 80 / 0.08);
            --shadow-lg: 0 12px 32px oklch(0.2 0.01 80 / 0.10);
            --font-body: 'Inter', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            --space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px;
            --space-5: 20px; --space-6: 24px; --space-8: 32px; --space-10: 40px;
            --text-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
            --text-sm: clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
            --text-base: clamp(1rem, 0.95rem + 0.25vw, 1.125rem);
            --text-lg: clamp(1.125rem, 1rem + 0.75vw, 1.5rem);
            --text-xl: clamp(1.5rem, 1.2rem + 1.25vw, 2.25rem);
            --transition: 160ms cubic-bezier(0.16, 1, 0.3, 1);
        }
        html { -webkit-font-smoothing: antialiased; scroll-behavior: smooth; }
        body { font-family: var(--font-body); font-size: var(--text-base); color: var(--color-text); background: var(--color-bg); min-height: 100dvh; line-height: 1.6; }
        a { color: inherit; text-decoration: none; }
        button, input { font: inherit; color: inherit; }
        img { display: block; max-width: 100%; }

        /* ── Header ── */
        .header {
            height: 56px;
            background: var(--color-surface);
            border-bottom: 1px solid var(--color-divider);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 var(--space-6);
            position: sticky;
            top: 0;
            z-index: 100;
            box-shadow: var(--shadow-sm);
        }
        .header-logo {
            display: flex;
            align-items: center;
            gap: var(--space-2);
            font-size: 15px;
            font-weight: 700;
            color: var(--color-text);
            letter-spacing: -0.2px;
        }
        .header-logo svg { color: var(--color-primary); }
        .header-nav {
            display: flex;
            align-items: center;
            gap: var(--space-1);
        }
        .header-nav a {
            font-size: var(--text-sm);
            color: var(--color-text-muted);
            padding: 6px 10px;
            border-radius: var(--radius-md);
            transition: background var(--transition), color var(--transition);
            display: flex;
            align-items: center;
            gap: 4px;
            position: relative;
        }
        .header-nav a:hover { background: var(--color-surface-2); color: var(--color-text); }
        .header-nav a.active { color: var(--color-primary); background: var(--color-primary-bg); }
        .nav-badge {
            position: absolute;
            top: 2px; right: 2px;
            background: #e53e3e;
            color: #fff;
            border-radius: var(--radius-full);
            font-size: 10px;
            min-width: 16px;
            height: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0 4px;
            line-height: 1;
            font-weight: 600;
        }

        /* ── Container ── */
        .container { max-width: 900px; margin: var(--space-8) auto; padding: 0 var(--space-4) var(--space-10); }
        .page-title { font-size: var(--text-xl); font-weight: 700; margin-bottom: var(--space-6); letter-spacing: -0.5px; }

        /* ── Tabs ── */
        .tabs { display: flex; gap: var(--space-2); margin-bottom: var(--space-6); }
        .tab {
            display: flex;
            align-items: center;
            gap: 6px;
            padding: 8px 18px;
            border-radius: var(--radius-full);
            border: 1px solid var(--color-border);
            background: var(--color-surface);
            color: var(--color-text-muted);
            font-size: var(--text-sm);
            font-weight: 500;
            transition: all var(--transition);
        }
        .tab:hover { border-color: var(--color-primary); color: var(--color-primary); }
        .tab.active { background: var(--color-primary); color: #fff; border-color: var(--color-primary); }

        /* ── Alert ── */
        .alert {
            display: flex;
            align-items: center;
            gap: var(--space-3);
            padding: 12px 16px;
            border-radius: var(--radius-md);
            margin-bottom: var(--space-4);
            font-size: var(--text-sm);
            border: 1px solid;
        }
        .alert-success { background: var(--color-success-bg); color: var(--color-success); border-color: var(--color-success-border); }
        .alert-error   { background: var(--color-error-bg);   color: var(--color-error);   border-color: var(--color-error-border); }

        /* ── Order Card ── */
        .order-card {
            background: var(--color-surface);
            border-radius: var(--radius-xl);
            border: 1px solid var(--color-border);
            padding: var(--space-5);
            margin-bottom: var(--space-4);
            box-shadow: var(--shadow-sm);
            transition: box-shadow var(--transition), border-color var(--transition);
        }
        .order-card:hover { box-shadow: var(--shadow-md); border-color: oklch(0.2 0.01 80 / 0.18); }
        .order-row { display: flex; gap: var(--space-4); align-items: flex-start; }
        .order-cover {
            width: 100px;
            height: 100px;
            object-fit: cover;
            border-radius: var(--radius-lg);
            background: var(--color-surface-2);
            flex-shrink: 0;
            border: 1px solid var(--color-border);
        }
        .cover-placeholder {
            width: 100px;
            height: 100px;
            border-radius: var(--radius-lg);
            background: var(--color-surface-2);
            border: 1px solid var(--color-border);
            flex-shrink: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 4px;
            color: var(--color-text-faint);
        }
        .cover-placeholder svg { width: 28px; height: 28px; }
        .cover-placeholder span { font-size: 11px; }
        .order-main { flex: 1; min-width: 0; }
        .order-head { display: flex; align-items: center; gap: var(--space-2); margin-bottom: 6px; flex-wrap: wrap; }
        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 3px 10px;
            border-radius: var(--radius-full);
            font-size: var(--text-xs);
            font-weight: 600;
            line-height: 1;
        }
        .badge-created   { background: #dbeafe; color: #1d4ed8; }
        .badge-paid      { background: var(--color-warning-bg); color: var(--color-warning); }
        .badge-cancelled { background: var(--color-neutral-bg); color: var(--color-neutral-text); }
        .badge-completed { background: var(--color-success-bg); color: var(--color-success); }
        .badge-disputed  { background: var(--color-error-bg); color: var(--color-error); }
        .order-title {
            font-size: var(--text-base);
            font-weight: 600;
            color: var(--color-text);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .order-meta {
            font-size: var(--text-xs);
            color: var(--color-text-muted);
            line-height: 1.9;
            margin-top: 4px;
        }
        .order-meta strong { color: var(--color-text); font-weight: 600; }
        .pickup-code-wrap { display: flex; align-items: center; gap: var(--space-2); margin-top: 4px; }
        .pickup-label { font-size: var(--text-xs); color: var(--color-text-muted); }
        .pickup-code {
            display: inline-block;
            background: var(--color-warning-bg);
            color: var(--color-warning);
            border: 1px solid var(--color-warning-border);
            border-radius: var(--radius-sm);
            padding: 2px 12px;
            font-size: 18px;
            font-weight: 700;
            letter-spacing: 4px;
        }
        .order-actions { margin-top: var(--space-3); display: flex; gap: var(--space-2); flex-wrap: wrap; align-items: center; }

        /* ── Buttons ── */
        .btn {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 7px 14px;
            border-radius: var(--radius-md);
            font-size: var(--text-sm);
            font-weight: 500;
            border: 1px solid transparent;
            cursor: pointer;
            transition: all var(--transition);
            line-height: 1;
        }
        .btn-primary { background: var(--color-primary); color: #fff; border-color: var(--color-primary); }
        .btn-primary:hover { background: var(--color-primary-hover); border-color: var(--color-primary-hover); }
        .btn-danger { background: var(--color-error-bg); color: var(--color-error); border-color: var(--color-error-border); }
        .btn-danger:hover { background: #f3e0ec; }
        .btn-ghost { background: transparent; color: var(--color-text-muted); border-color: var(--color-border); }
        .btn-ghost:hover { color: var(--color-text); border-color: oklch(0.2 0.01 80 / 0.25); background: var(--color-surface-2); }
        .btn-disabled { background: var(--color-neutral-bg); color: var(--color-text-faint); border-color: transparent; cursor: not-allowed; }

        /* ── Empty ── */
        .empty-state {
            background: var(--color-surface);
            border-radius: var(--radius-xl);
            border: 1px solid var(--color-border);
            padding: 72px 24px;
            text-align: center;
            color: var(--color-text-muted);
            box-shadow: var(--shadow-sm);
        }
        .empty-state svg { width: 48px; height: 48px; color: var(--color-text-faint); margin: 0 auto var(--space-4); }
        .empty-state p { font-size: var(--text-sm); margin-top: var(--space-2); }

        /* ── Pagination ── */
        .pagination { display: flex; justify-content: center; align-items: center; gap: 6px; margin-top: var(--space-8); flex-wrap: wrap; }
        .page-btn {
            min-width: 36px;
            height: 36px;
            padding: 0 10px;
            border-radius: var(--radius-md);
            border: 1px solid var(--color-border);
            background: var(--color-surface);
            color: var(--color-text-muted);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: var(--text-sm);
            transition: all var(--transition);
        }
        .page-btn:hover { border-color: var(--color-primary); color: var(--color-primary); }
        .page-btn.active { background: var(--color-primary); color: #fff; border-color: var(--color-primary); font-weight: 600; }
        .page-btn.disabled { pointer-events: none; color: var(--color-text-faint); border-color: #eee; }
        .page-info { font-size: var(--text-xs); color: var(--color-text-muted); margin-left: 4px; }

        @media (max-width: 600px) {
            .order-row { flex-direction: column; }
            .order-cover, .cover-placeholder { width: 100%; height: 180px; }
            .header-nav a span { display: none; }
        }
    </style>
</head>
<body>

<!-- Header -->
<header class="header">
    <a href="${pageContext.request.contextPath}/index.jsp" class="header-logo">
        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span>民大二手交易平台</span>
    </a>
    <nav class="header-nav" aria-label="主导航">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            <span>首页</span>
        </a>
        <a href="${pageContext.request.contextPath}/pickup-locations.jsp">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
            <span>自提点</span>
        </a>
        <a href="${pageContext.request.contextPath}/product-list">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><line x1="8" y1="21" x2="16" y2="21"/><line x1="12" y1="17" x2="12" y2="21"/></svg>
            <span>商品列表</span>
        </a>
        <% if (loginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-products">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 7H4a2 2 0 0 0-2 2v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2z"/><path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/></svg>
                <span>我的商品</span>
            </a>
            <a href="${pageContext.request.contextPath}/orders" class="active">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/></svg>
                <span>我的订单</span>
            </a>
            <a href="${pageContext.request.contextPath}/messages">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                <span>私信</span>
            </a>
            <a href="${pageContext.request.contextPath}/my-favorites">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                <span>收藏</span>
            </a>
            <a href="${pageContext.request.contextPath}/notifications" style="position:relative;">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                <span>通知</span>
                <% if (unreadNotifyCount > 0) { %>
                <span class="nav-badge" aria-label="<%= unreadNotifyCount %>条未读"><%= unreadNotifyCount %></span>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/logout">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
                <span>退出</span>
            </a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
                <span>登录</span>
            </a>
        <% } %>
    </nav>
</header>

<div class="container">
    <h1 class="page-title">我的订单</h1>

    <!-- Tabs -->
    <div class="tabs">
        <a class="tab<% if("buy".equals(type)){out.print(" active");}%>" href="${pageContext.request.contextPath}/orders?type=buy">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
            我买到的
        </a>
        <a class="tab<% if("sell".equals(type)){out.print(" active");}%>" href="${pageContext.request.contextPath}/orders?type=sell">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/></svg>
            我卖出的
        </a>
    </div>

    <!-- Alerts -->
    <% if (successMsg != null) { %>
        <div class="alert alert-success" role="alert">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
            <%= successMsg %>
        </div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="alert alert-error" role="alert">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            <%= errorMsg %>
        </div>
    <% } %>

    <!-- Order List -->
    <% if (orderList.isEmpty()) { %>
        <div class="empty-state">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
            <strong>暂无订单记录</strong>
            <p>你还没有任何订单，去逛逛商品列表吧。</p>
        </div>
    <% } else { %>
        <% for (Map<String, Object> o : orderList) { %>
        <%
            String status = (String) o.get("orderStatus");
            String sText;
            if ("CREATED".equals(status))          sText = "待交易";
            else if ("PAID_OFFLINE".equals(status)) sText = "线下已成交";
            else if ("CANCELLED".equals(status))    sText = "已取消";
            else if ("COMPLETED".equals(status))    sText = "已完成";
            else if ("DISPUTED".equals(status))     sText = "纠纷中";
            else sText = (status != null ? status : "未知");
            String badgeClass;
            if ("CREATED".equals(status))          badgeClass = "badge-created";
            else if ("PAID_OFFLINE".equals(status)) badgeClass = "badge-paid";
            else if ("CANCELLED".equals(status))    badgeClass = "badge-cancelled";
            else if ("COMPLETED".equals(status))    badgeClass = "badge-completed";
            else if ("DISPUTED".equals(status))     badgeClass = "badge-disputed";
            else badgeClass = "badge-cancelled";
        %>
        <div class="order-card">
            <div class="order-row">
                <% String coverUrl = (String) o.get("coverImageUrl"); %>
                <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
                    <img class="order-cover" src="<%= coverUrl %>" alt="商品图" loading="lazy" width="100" height="100">
                <% } else { %>
                    <div class="cover-placeholder" aria-hidden="true">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        <span>暂无图片</span>
                    </div>
                <% } %>
                <div class="order-main">
                    <div class="order-head">
                        <span class="status-badge <%= badgeClass %>"><%= sText %></span>
                    </div>
                    <div class="order-title"><%= o.get("title") != null ? o.get("title") : "商品已删除" %></div>
                    <div class="order-meta">
                        订单号：<%= o.get("orderNo") %>&emsp;
                        成交价：<strong>&yen;<%= o.get("dealPrice") %></strong>&emsp;
                        数量：<%= o.get("quantity") %><br>
                        买家：<%= o.get("buyerName") %>&ensp;|&ensp;卖家：<%= o.get("sellerName") %><br>
                        创建时间：<%= o.get("createdAt") %>
                        <% if (o.get("paidAt") != null) { %>&emsp;成交：<%= o.get("paidAt") %><% } %>
                        <% if (o.get("completedAt") != null) { %>&emsp;完成：<%= o.get("completedAt") %><% } %>
                        <% if (o.get("cancelledAt") != null) { %>&emsp;取消：<%= o.get("cancelledAt") %><% } %>
                        <% if (o.get("buyerNote") != null) { %><br>买家备注：<%= o.get("buyerNote") %><% } %>
                        <% if (o.get("sellerNote") != null) { %><br>卖家备注：<%= o.get("sellerNote") %><% } %>
                    </div>
                    <%
                        String pc = (String) o.get("pickupCode");
                        boolean showPc = pc != null && !pc.isEmpty()
                            && ("PAID_OFFLINE".equals(status) || "COMPLETED".equals(status));
                    %>
                    <% if (showPc) { %>
                        <div class="pickup-code-wrap">
                            <span class="pickup-label">取货码</span>
                            <span class="pickup-code"><%= pc %></span>
                        </div>
                    <% } %>
                    <div class="order-actions">
                        <% Object pid = o.get("productId"); %>
                        <% if (pid != null) { %>
                            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/product-detail?id=<%= pid %>">
                                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                                查看商品
                            </a>
                        <% } %>
                        <% if ("buy".equals(type) && "CREATED".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确定要取消该订单吗？');">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="buy">
                                <button class="btn btn-danger" type="submit">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                                    取消订单
                                </button>
                            </form>
                        <% } %>
                        <% if ("sell".equals(type) && "CREATED".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确认已与买家完成线下交易吗？');">
                                <input type="hidden" name="action" value="paid">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="sell">
                                <button class="btn btn-primary" type="submit">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    确认线下成交
                                </button>
                            </form>
                        <% } %>
                        <% if ("buy".equals(type) && "PAID_OFFLINE".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确认交易已完成吗？');">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="buy">
                                <button class="btn btn-primary" type="submit">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="20 6 9 17 4 12"/></svg>
                                    确认完成
                                </button>
                            </form>
                        <% } %>
                        <% if ("CREATED".equals(status) || "PAID_OFFLINE".equals(status)) { %>
                            <form action="${pageContext.request.contextPath}/orders" method="post" style="margin:0;" onsubmit="return confirm('确定要对此订单发起纠纷吗？');">
                                <input type="hidden" name="action" value="dispute">
                                <input type="hidden" name="orderId" value="<%= o.get("orderId") %>">
                                <input type="hidden" name="type" value="<%= type %>">
                                <button class="btn btn-danger" type="submit">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>
                                    发起纠纷
                                </button>
                            </form>
                        <% } %>
                        <% if ("COMPLETED".equals(status)) {
                            Boolean hasReviewed = (Boolean) o.get("hasReviewed");
                            if (hasReviewed != null && hasReviewed) { %>
                                <span class="btn btn-disabled">已评价</span>
                            <% } else { %>
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/review?orderId=<%= o.get("orderId") %>">
                                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"/></svg>
                                    去评价
                                </a>
                            <% }
                        } %>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    <% } %>

    <!-- Pagination -->
    <% if (totalPages > 1) { %>
    <nav class="pagination" aria-label="分页">
        <a class="page-btn<% if(currentPage==1){out.print(" disabled");}%>" href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= currentPage-1 %>" aria-label="上一页">&lsaquo;</a>
        <%
            int startP = Math.max(1, currentPage - 2);
            int endP   = Math.min(totalPages, currentPage + 2);
        %>
        <% if (startP > 1) { %>
            <a class="page-btn" href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=1">1</a>
            <% if (startP > 2) { %><span style="color:var(--color-text-faint);font-size:var(--text-sm)">…</span><% } %>
        <% } %>
        <% for (int p = startP; p <= endP; p++) { %>
            <a class="page-btn<% if(p==currentPage){out.print(" active");}%>" href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= p %>"><%= p %></a>
        <% } %>
        <% if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span style="color:var(--color-text-faint);font-size:var(--text-sm)">…</span><% } %>
            <a class="page-btn" href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= totalPages %>"><%= totalPages %></a>
        <% } %>
        <a class="page-btn<% if(currentPage==totalPages){out.print(" disabled");}%>" href="${pageContext.request.contextPath}/orders?type=<%= type %>&page=<%= currentPage+1 %>" aria-label="下一页">&rsaquo;</a>
        <span class="page-info">共 <%= totalCount %> 条</span>
    </nav>
    <% } %>
</div>

</body>
</html>
