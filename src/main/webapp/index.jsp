<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>首页 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:         #f4f3ef;
            --surface:    #ffffff;
            --surface2:   #f9f8f6;
            --border:     rgba(0,0,0,0.08);
            --text:       #1a1a1a;
            --text-muted: #737373;
            --text-faint: #b0b0b0;
            --primary:    #0b6e63;
            --primary-h:  #085c52;
            --primary-hl: #d0eae7;
            --orange:     #d97706;
            --orange-bg:  #fef3c7;
            --purple:     #7c3aed;
            --purple-bg:  #f5f3ff;
            --radius-sm:  8px;
            --radius:     14px;
            --shadow-sm:  0 2px 8px rgba(0,0,0,0.06);
            --shadow:     0 8px 28px rgba(0,0,0,0.08);
            --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --nav-h:      60px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; scroll-behavior: smooth; }
        body {
            font-family: var(--font);
            background: var(--bg);
            color: var(--text);
            min-height: 100dvh;
            font-size: 15px;
            line-height: 1.6;
        }
        a { text-decoration: none; color: inherit; }
        button { cursor: pointer; font-family: var(--font); }

        /* NAV */
        .nav {
            height: var(--nav-h);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .nav-brand { display: flex; align-items: center; gap: 9px; }
        .nav-logo {
            width: 34px; height: 34px;
            background: var(--primary);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; flex-shrink: 0;
        }
        .nav-brand-name { font-size: 15px; font-weight: 700; color: var(--text); letter-spacing: 0.01em; }
        .nav-links { display: flex; align-items: center; gap: 2px; list-style: none; }
        .nav-links a {
            font-size: 14px; font-weight: 500; color: var(--text-muted);
            padding: 7px 12px; border-radius: 7px;
            transition: color 0.15s, background 0.15s;
            display: flex; align-items: center; gap: 5px;
        }
        .nav-links a:hover { color: var(--text); background: var(--bg); }
        .nav-links a.active { color: var(--primary); background: var(--primary-hl); }
        .nav-right { display: flex; align-items: center; gap: 10px; }
        .user-chip {
            display: flex; align-items: center; gap: 7px;
            padding: 5px 12px 5px 6px;
            border-radius: 99px;
            background: var(--bg);
            border: 1px solid var(--border);
            font-size: 13px; font-weight: 500; color: var(--text-muted);
            cursor: default;
        }
        .user-avatar {
            width: 26px; height: 26px;
            background: var(--primary); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 12px; font-weight: 700; flex-shrink: 0;
        }
        .logout-link {
            font-size: 13px; color: var(--text-muted);
            padding: 7px 10px; border-radius: 7px;
            transition: color 0.15s, background 0.15s;
        }
        .logout-link:hover { color: #ef4444; background: #fff1f1; }

        /* MAIN */
        .main { max-width: 1100px; margin: 0 auto; padding: 36px 24px 64px; }

        /* WELCOME CARD */
        .welcome-card {
            background: var(--primary);
            border-radius: var(--radius);
            padding: 36px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 32px;
            overflow: hidden;
            position: relative;
        }
        .welcome-card::before {
            content: '';
            position: absolute;
            width: 280px; height: 280px;
            background: rgba(255,255,255,0.05);
            border-radius: 50%;
            right: -70px; top: -100px;
            pointer-events: none;
        }
        .welcome-card::after {
            content: '';
            position: absolute;
            width: 160px; height: 160px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            left: 62%; bottom: -55px;
            pointer-events: none;
        }
        .welcome-greeting { font-size: 13px; color: rgba(255,255,255,0.6); font-weight: 500; margin-bottom: 6px; letter-spacing: 0.02em; }
        .welcome-name { font-size: clamp(22px, 3vw, 30px); font-weight: 700; color: #fff; margin-bottom: 8px; }
        .welcome-meta { font-size: 13px; color: rgba(255,255,255,0.58); display: flex; gap: 20px; }
        .welcome-meta span { display: flex; align-items: center; gap: 4px; }
        .welcome-actions { display: flex; gap: 10px; flex-shrink: 0; }
        .btn-white {
            padding: 10px 22px;
            background: #fff; color: var(--primary);
            border: none; border-radius: 9px;
            font-size: 14px; font-weight: 600; font-family: var(--font);
            cursor: pointer; transition: opacity 0.15s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-white:hover { opacity: 0.88; }
        .btn-ghost-white {
            padding: 10px 18px;
            background: rgba(255,255,255,0.12); color: #fff;
            border: 1.5px solid rgba(255,255,255,0.25);
            border-radius: 9px;
            font-size: 14px; font-weight: 600; font-family: var(--font);
            cursor: pointer; transition: background 0.15s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-ghost-white:hover { background: rgba(255,255,255,0.2); }

        /* SECTION TITLE */
        .section-title {
            font-size: 16px; font-weight: 700; color: var(--text);
            margin-bottom: 14px; letter-spacing: 0.01em;
        }

        /* ACTIONS GRID */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 12px;
            margin-bottom: 36px;
        }
        .action-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 20px 20px;
            display: flex;
            align-items: center;
            gap: 14px;
            transition: box-shadow 0.18s, transform 0.18s, border-color 0.18s;
            cursor: pointer;
        }
        .action-card:hover {
            box-shadow: var(--shadow);
            transform: translateY(-2px);
            border-color: transparent;
        }
        .action-icon {
            width: 38px; height: 38px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
            color: var(--text-muted);
        }
        .action-icon svg { width: 22px; height: 22px; }
        .action-text { flex: 1; }
        .action-label { font-size: 14px; font-weight: 600; color: var(--text); margin-bottom: 2px; }
        .action-desc { font-size: 12px; color: var(--text-muted); line-height: 1.4; }
        .action-arrow {
            color: var(--text-faint);
            flex-shrink: 0;
            transition: transform 0.15s, color 0.15s;
        }
        .action-card:hover .action-arrow { transform: translateX(3px); color: var(--primary); }

        /* ADMIN BANNER */
        .admin-section {
            background: var(--purple-bg);
            border: 1px solid rgba(124,58,237,0.14);
            border-radius: var(--radius);
            padding: 18px 24px;
            margin-bottom: 36px;
            display: flex;
            align-items: center;
            gap: 14px;
        }
        .admin-icon {
            width: 36px; height: 36px;
            background: var(--purple);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; flex-shrink: 0;
        }
        .admin-text { flex: 1; }
        .admin-title { font-size: 13.5px; font-weight: 700; color: var(--purple); margin-bottom: 1px; }
        .admin-desc { font-size: 12.5px; color: #6d28d9; opacity: 0.72; }
        .admin-links { display: flex; gap: 8px; flex-shrink: 0; }
        .btn-purple {
            padding: 7px 15px;
            background: var(--purple); color: #fff;
            border: none; border-radius: 7px;
            font-size: 13px; font-weight: 600; font-family: var(--font);
            cursor: pointer; transition: opacity 0.15s;
        }
        .btn-purple:hover { opacity: 0.85; }

        @media (max-width: 768px) {
            .nav { padding: 0 16px; }
            .nav-links { display: none; }
            .welcome-card { flex-direction: column; align-items: flex-start; gap: 22px; padding: 26px 22px; }
            .welcome-actions { width: 100%; }
            .btn-white, .btn-ghost-white { flex: 1; justify-content: center; }
            .admin-section { flex-wrap: wrap; }
            .admin-links { width: 100%; }
            .actions-grid { grid-template-columns: 1fr 1fr; }
        }
        @media (max-width: 420px) {
            .actions-grid { grid-template-columns: 1fr; }
        }

        /* PRODUCTS GRID */
        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 16px;
            margin-bottom: 24px;
        }
        .product-card-link {
            text-decoration: none;
            color: inherit;
        }
        .product-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            overflow: hidden;
            transition: box-shadow 0.2s, transform 0.2s, border-color 0.2s;
        }
        .product-card:hover {
            box-shadow: var(--shadow);
            transform: translateY(-3px);
            border-color: transparent;
        }
        .product-cover {
            width: 100%;
            height: 180px;
            object-fit: cover;
            background: #f3f4f6;
        }
        .product-cover-empty {
            width: 100%;
            height: 180px;
            background: #f3f4f6;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            color: var(--text-faint);
            font-size: 13px;
            gap: 8px;
        }
        .product-info {
            padding: 14px;
        }
        .product-title {
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            line-height: 1.45;
            margin-bottom: 8px;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .product-price {
            font-size: 18px;
            font-weight: 700;
            color: #c2410c;
            margin-bottom: 8px;
        }
        .product-meta {
            display: flex;
            gap: 6px;
            flex-wrap: wrap;
        }
        .product-tag {
            font-size: 11px;
            color: var(--text-muted);
            background: var(--bg);
            padding: 2px 8px;
            border-radius: 4px;
        }
        .btn-view-all {
            display: inline-block;
            padding: 10px 24px;
            background: var(--primary);
            color: #fff;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            transition: background 0.15s;
        }
        .btn-view-all:hover {
            background: var(--primary-h);
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
        <li><a href="${pageContext.request.contextPath}/index.jsp" class="active">首页</a></li>
        <li><a href="${pageContext.request.contextPath}/pickup-locations.jsp">自提点</a></li>
        <li><a href="${pageContext.request.contextPath}/product-list">浏览商品</a></li>
        <li><a href="${pageContext.request.contextPath}/my-products">我的商品</a></li>
    </ul>
    <div class="nav-right">
        <div class="user-chip">
            <div class="user-avatar"><%= loginUser.getRealName() != null && !loginUser.getRealName().isEmpty() ? loginUser.getRealName().substring(0,1) : "U" %></div>
            <%= loginUser.getRealName() %>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="logout-link">退出</a>
    </div>
</nav>

<main class="main">

    <!-- Welcome Banner -->
    <div class="welcome-card">
        <div class="welcome-left">
            <div class="welcome-greeting">欢迎回来</div>
            <div class="welcome-name"><%= loginUser.getRealName() %></div>
            <div class="welcome-meta">
                <span>
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/></svg>
                    <%= loginUser.getStudentOrStaffNo() %>
                </span>
                <span>
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                    <%= "ADMIN".equals(loginUser.getRoleCode()) ? "管理员" : "普通用户" %>
                </span>
            </div>
        </div>
        <div class="welcome-actions">
            <a href="${pageContext.request.contextPath}/product-list">
                <button class="btn-white">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                    浏览商品
                </button>
            </a>
            <a href="${pageContext.request.contextPath}/publish-product">
                <button class="btn-ghost-white">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.3" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    发布商品
                </button>
            </a>
        </div>
    </div>

    <!-- Admin Banner (Admin only) -->
    <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
    <div class="admin-section">
        <div class="admin-icon" aria-hidden="true">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/></svg>
        </div>
        <div class="admin-text">
            <div class="admin-title">管理员控制台</div>
            <div class="admin-desc">你拥有管理员权限，可以审核用户与商品、查看数据报告</div>
        </div>
        <div class="admin-links">
            <a href="${pageContext.request.contextPath}/admin/user-review"><button class="btn-purple">用户审核</button></a>
            <a href="${pageContext.request.contextPath}/admin/dashboard"><button class="btn-purple">数据面板</button></a>
        </div>
    </div>
    <% } %>

    <!-- Quick Actions -->
    <div class="section-title">快捷入口</div>
    <div class="actions-grid">

        <a href="${pageContext.request.contextPath}/product-list">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">浏览商品</div>
                    <div class="action-desc">查看全部在售二手好物</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/publish-product">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="17 8 12 3 7 8"/><line x1="12" y1="3" x2="12" y2="15"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">发布商品</div>
                    <div class="action-desc">把闲置挂出来，让它找到新主人</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/my-products">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">我的商品</div>
                    <div class="action-desc">管理已发布的商品</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/orders">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="16" y1="13" x2="8" y2="13"/><line x1="16" y1="17" x2="8" y2="17"/><polyline points="10 9 9 9 8 9"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">我的订单</div>
                    <div class="action-desc">查看买卖交易记录</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/my-favorites">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">我的收藏</div>
                    <div class="action-desc">看看收藏的心仪好物</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/messages">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">我的私信</div>
                    <div class="action-desc">与买家或卖家沟通交流</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/notifications">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">通知中心</div>
                    <div class="action-desc">查看平台系统通知</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

        <a href="${pageContext.request.contextPath}/pickup-locations.jsp">
            <div class="action-card">
                <div class="action-icon" aria-hidden="true">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                </div>
                <div class="action-text">
                    <div class="action-label">自提点</div>
                    <div class="action-desc">查看校内自提交货地点</div>
                </div>
                <div class="action-arrow" aria-hidden="true">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"/></svg>
                </div>
            </div>
        </a>

    </div>

    <!-- Latest Products -->
    <%
        List<Product> latestProducts = (List<Product>) request.getAttribute("latestProducts");
        if (latestProducts != null && !latestProducts.isEmpty()) {
    %>
    <div class="section-title" style="margin-top: 36px;">最新上架</div>
    <div class="products-grid">
        <% for (Product p : latestProducts) {
            String condText = "成色未填";
            if (p.getConditionLevel() != null) {
                switch (p.getConditionLevel()) {
                    case "NEW": condText = "全新"; break;
                    case "NINETY_NEW": condText = "九成新"; break;
                    case "EIGHTY_NEW": condText = "八成新"; break;
                    case "SEVENTY_NEW": condText = "七成新及以下"; break;
                    default: condText = p.getConditionLevel();
                }
            }
        %>
        <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="product-card-link">
            <div class="product-card">
                <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" class="product-cover" loading="lazy">
                <% } else { %>
                    <div class="product-cover-empty">
                        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>
                        <span>暂无图片</span>
                    </div>
                <% } %>
                <div class="product-info">
                    <div class="product-title"><%= p.getTitle() %></div>
                    <div class="product-price">¥<%= p.getPrice() %></div>
                    <div class="product-meta">
                        <span class="product-tag"><%= condText %></span>
                        <span class="product-tag"><%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %></span>
                    </div>
                </div>
            </div>
        </a>
        <% } %>
    </div>
    <div style="text-align: center; margin-top: 20px;">
        <a href="${pageContext.request.contextPath}/product-list" class="btn-view-all">查看全部商品 →</a>
    </div>
    <% } %>

</main>

</body>
</html>
