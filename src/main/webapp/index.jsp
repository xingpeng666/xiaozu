<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
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
            --orange-bg:  #fffbeb;
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

        /* ── NAV ── */
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
        .nav-brand {
            display: flex;
            align-items: center;
            gap: 9px;
        }
        .nav-logo {
            width: 34px; height: 34px;
            background: var(--primary);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: #fff;
            flex-shrink: 0;
        }
        .nav-brand-name {
            font-size: 15px;
            font-weight: 700;
            color: var(--text);
            letter-spacing: 0.01em;
        }
        .nav-links {
            display: flex;
            align-items: center;
            gap: 2px;
            list-style: none;
        }
        .nav-links a {
            font-size: 14px;
            font-weight: 500;
            color: var(--text-muted);
            padding: 7px 12px;
            border-radius: 7px;
            transition: color 0.15s, background 0.15s;
            display: flex; align-items: center; gap: 5px;
        }
        .nav-links a:hover { color: var(--text); background: var(--bg); }
        .nav-links a.active { color: var(--primary); background: var(--primary-hl); }
        .nav-links .badge {
            background: #ef4444;
            color: #fff;
            border-radius: 10px;
            font-size: 10px;
            line-height: 1;
            padding: 2px 5px;
            font-weight: 700;
        }
        .nav-right {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .user-chip {
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 5px 12px 5px 6px;
            border-radius: 99px;
            background: var(--bg);
            border: 1px solid var(--border);
            font-size: 13px;
            font-weight: 500;
            color: var(--text-muted);
            cursor: default;
        }
        .user-avatar {
            width: 26px; height: 26px;
            background: var(--primary);
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            color: #fff;
            font-size: 12px;
            font-weight: 700;
            flex-shrink: 0;
        }
        .logout-link {
            font-size: 13px;
            color: var(--text-muted);
            padding: 7px 10px;
            border-radius: 7px;
            transition: color 0.15s, background 0.15s;
        }
        .logout-link:hover { color: #ef4444; background: #fff1f1; }

        /* ── MAIN ── */
        .main {
            max-width: 1100px;
            margin: 0 auto;
            padding: 36px 24px 64px;
        }

        /* ── HERO WELCOME ── */
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
            width: 300px; height: 300px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            right: -80px; top: -100px;
        }
        .welcome-card::after {
            content: '';
            position: absolute;
            width: 180px; height: 180px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            left: 60%; bottom: -60px;
        }
        .welcome-left {}
        .welcome-greeting {
            font-size: 13px;
            color: rgba(255,255,255,0.65);
            font-weight: 500;
            margin-bottom: 6px;
            letter-spacing: 0.02em;
        }
        .welcome-name {
            font-size: clamp(22px, 3vw, 30px);
            font-weight: 700;
            color: #fff;
            margin-bottom: 8px;
        }
        .welcome-meta {
            font-size: 13px;
            color: rgba(255,255,255,0.6);
            display: flex;
            gap: 16px;
        }
        .welcome-meta span { display: flex; align-items: center; gap: 5px; }
        .welcome-actions {
            display: flex;
            gap: 10px;
            flex-shrink: 0;
        }
        .btn-white {
            padding: 10px 22px;
            background: #fff;
            color: var(--primary);
            border: none;
            border-radius: 9px;
            font-size: 14px;
            font-weight: 600;
            font-family: var(--font);
            cursor: pointer;
            transition: opacity 0.15s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-white:hover { opacity: 0.88; }
        .btn-ghost-white {
            padding: 10px 18px;
            background: rgba(255,255,255,0.12);
            color: #fff;
            border: 1.5px solid rgba(255,255,255,0.25);
            border-radius: 9px;
            font-size: 14px;
            font-weight: 600;
            font-family: var(--font);
            cursor: pointer;
            transition: background 0.15s;
            display: inline-flex; align-items: center; gap: 6px;
        }
        .btn-ghost-white:hover { background: rgba(255,255,255,0.2); }

        /* ── SECTION TITLE ── */
        .section-title {
            font-size: 17px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 16px;
            letter-spacing: 0.01em;
        }

        /* ── QUICK ACTIONS ── */
        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 14px;
            margin-bottom: 36px;
        }
        .action-card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 24px 22px;
            display: flex;
            align-items: flex-start;
            gap: 16px;
            transition: box-shadow 0.18s, transform 0.18s, border-color 0.18s;
            cursor: pointer;
        }
        .action-card:hover {
            box-shadow: var(--shadow);
            transform: translateY(-2px);
            border-color: transparent;
        }
        .action-icon {
            width: 42px; height: 42px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            font-size: 18px;
            flex-shrink: 0;
        }
        .icon-teal { background: var(--primary-hl); }
        .icon-orange { background: var(--orange-bg); }
        .icon-purple { background: var(--purple-bg); }
        .icon-gray { background: #f3f4f6; }
        .action-text {
            flex: 1;
        }
        .action-label {
            font-size: 14px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 3px;
        }
        .action-desc {
            font-size: 12px;
            color: var(--text-muted);
        }

        /* ── ADMIN PANEL ── */
        .admin-section {
            background: var(--purple-bg);
            border: 1px solid rgba(124,58,237,0.12);
            border-radius: var(--radius);
            padding: 20px 24px;
            margin-bottom: 36px;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        .admin-icon {
            width: 40px; height: 40px;
            background: var(--purple);
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
            color: #fff;
            font-size: 18px;
            flex-shrink: 0;
        }
        .admin-text { flex: 1; }
        .admin-title { font-size: 14px; font-weight: 700; color: var(--purple); margin-bottom: 2px; }
        .admin-desc { font-size: 13px; color: #6d28d9; opacity: 0.7; }
        .admin-links {
            display: flex; gap: 8px; flex-shrink: 0;
        }
        .btn-purple {
            padding: 8px 16px;
            background: var(--purple);
            color: #fff;
            border: none;
            border-radius: 7px;
            font-size: 13px;
            font-weight: 600;
            font-family: var(--font);
            cursor: pointer;
            transition: opacity 0.15s;
        }
        .btn-purple:hover { opacity: 0.85; }

        @media (max-width: 768px) {
            .nav { padding: 0 16px; }
            .welcome-card { flex-direction: column; gap: 24px; padding: 28px 24px; }
            .welcome-actions { width: 100%; }
            .btn-white, .btn-ghost-white { flex: 1; justify-content: center; }
            .admin-section { flex-wrap: wrap; }
            .admin-links { width: 100%; }
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
            <div class="welcome-greeting">你好呀 👋</div>
            <div class="welcome-name"><%= loginUser.getRealName() %></div>
            <div class="welcome-meta">
                <span>学号/工号：<%= loginUser.getStudentOrStaffNo() %></span>
                <span>角色：<%= "ADMIN".equals(loginUser.getRoleCode()) ? "管理员" : "普通用户" %></span>
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
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>
                    发布商品
                </button>
            </a>
        </div>
    </div>

    <!-- Admin Panel (Admin only) -->
    <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
    <div class="admin-section">
        <div class="admin-icon">🛡</div>
        <div class="admin-text">
            <div class="admin-title">管理员控制台</div>
            <div class="admin-desc">你拥有管理员权限，可以审核用户和商品</div>
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
                <div class="action-icon icon-teal">🛍</div>
                <div class="action-text">
                    <div class="action-label">浏览商品</div>
                    <div class="action-desc">查看全部在售商品</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/publish-product">
            <div class="action-card">
                <div class="action-icon icon-orange">📤</div>
                <div class="action-text">
                    <div class="action-label">发布商品</div>
                    <div class="action-desc">把闲置挂出来卖</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/my-products">
            <div class="action-card">
                <div class="action-icon icon-teal">📦</div>
                <div class="action-text">
                    <div class="action-label">我的商品</div>
                    <div class="action-desc">管理已发布的商品</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/orders">
            <div class="action-card">
                <div class="action-icon icon-orange">📋</div>
                <div class="action-text">
                    <div class="action-label">我的订单</div>
                    <div class="action-desc">查看买卖订单记录</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/my-favorites">
            <div class="action-card">
                <div class="action-icon icon-gray">❤️</div>
                <div class="action-text">
                    <div class="action-label">我的收藏</div>
                    <div class="action-desc">看看收藏的好物</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/messages">
            <div class="action-card">
                <div class="action-icon icon-purple">💬</div>
                <div class="action-text">
                    <div class="action-label">我的私信</div>
                    <div class="action-desc">与卖家/买家沟通</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/notifications">
            <div class="action-card">
                <div class="action-icon icon-gray">🔔</div>
                <div class="action-text">
                    <div class="action-label">通知中心</div>
                    <div class="action-desc">查看系统通知</div>
                </div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/pickup-locations.jsp">
            <div class="action-card">
                <div class="action-icon icon-teal">📍</div>
                <div class="action-text">
                    <div class="action-label">自提点</div>
                    <div class="action-desc">查看校内自提地点</div>
                </div>
            </div>
        </a>
    </div>

</main>

</body>
</html>
