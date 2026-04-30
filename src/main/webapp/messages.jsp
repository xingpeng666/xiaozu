<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="java.util.*" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Map<String, Object>> conversations = (List<Map<String, Object>>) request.getAttribute("conversations");
    if (conversations == null) conversations = new ArrayList<>();
    String successMsg = (String) request.getAttribute("successMsg");
    if (successMsg == null) successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = (String) session.getAttribute("errorMsg");
    session.removeAttribute("successMsg");
    session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>私信 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:         #f4f3ef;
            --surface:    #ffffff;
            --border:     rgba(0,0,0,0.09);
            --text:       #1a1a1a;
            --text-muted: #737373;
            --primary:    #0b6e63;
            --primary-h:  #085c52;
            --primary-hl: #d0eae7;
            --error-bg:   #fff1f0;
            --error-bd:   #ffc5c5;
            --error-tx:   #b91c1c;
            --success-bg: #f0fdf4;
            --success-bd: #bbf7d0;
            --success-tx: #15803d;
            --radius:     12px;
            --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --shadow:     0 2px 12px rgba(0,0,0,0.06);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body { font-family: var(--font); background: var(--bg); color: var(--text); min-height: 100dvh; }

        /* NAV */
        .nav {
            height: 56px; background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 28px; position: sticky; top: 0; z-index: 100;
        }
        .nav-brand {
            display: flex; align-items: center; gap: 9px;
            font-size: 16px; font-weight: 700; color: var(--primary);
            text-decoration: none;
        }
        .nav-brand svg { color: var(--primary); }
        .nav-links { display: flex; align-items: center; gap: 4px; }
        .nav-links a {
            font-size: 13.5px; font-weight: 500; color: var(--text-muted);
            text-decoration: none; padding: 6px 11px; border-radius: 7px;
            transition: background 0.15s, color 0.15s;
        }
        .nav-links a:hover { background: var(--primary-hl); color: var(--primary); }
        .nav-links a.active { background: var(--primary-hl); color: var(--primary); }
        .nav-links .btn-logout {
            margin-left: 6px; padding: 6px 14px;
            background: var(--primary); color: #fff; border-radius: 7px;
        }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }

        /* LAYOUT */
        .container { max-width: 700px; margin: 36px auto; padding: 0 16px; }
        .page-header { margin-bottom: 24px; }
        .page-header h1 { font-size: 22px; font-weight: 700; color: var(--text); }
        .page-header p { font-size: 14px; color: var(--text-muted); margin-top: 4px; }

        /* ALERT */
        .alert {
            padding: 11px 14px; border-radius: 8px; font-size: 13.5px;
            margin-bottom: 18px; display: flex; align-items: flex-start;
            gap: 8px; line-height: 1.5;
        }
        .alert-error  { background: var(--error-bg);   border: 1px solid var(--error-bd);   color: var(--error-tx); }
        .alert-success{ background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); }

        /* CONVERSATION LIST */
        .conv-list { display: flex; flex-direction: column; gap: 6px; }
        .conv-item {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            display: flex; align-items: center; gap: 14px;
            padding: 14px 16px;
            text-decoration: none; color: inherit;
            transition: box-shadow 0.15s, border-color 0.15s;
            box-shadow: var(--shadow);
        }
        .conv-item:hover {
            border-color: var(--primary-hl);
            box-shadow: 0 4px 18px rgba(11,110,99,0.09);
        }
        .avatar {
            width: 44px; height: 44px; border-radius: 50%;
            background: var(--primary); color: #fff; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 17px; font-weight: 700;
        }
        .conv-info { flex: 1; min-width: 0; }
        .conv-name  { font-size: 14.5px; font-weight: 600; margin-bottom: 3px; }
        .conv-preview {
            font-size: 13px; color: var(--text-muted);
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .conv-right { text-align: right; flex-shrink: 0; }
        .conv-time  { font-size: 12px; color: #b0b0b0; margin-bottom: 6px; }
        .unread-badge {
            display: inline-block; background: #ef4444; color: #fff;
            font-size: 11px; font-weight: 700;
            min-width: 18px; height: 18px; padding: 0 5px;
            border-radius: 9px; text-align: center; line-height: 18px;
        }

        /* EMPTY */
        .empty-box {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty-box p { font-size: 14.5px; color: var(--text-muted); margin-bottom: 18px; }
        .btn-primary {
            display: inline-block;
            padding: 10px 22px; background: var(--primary); color: #fff;
            border-radius: 8px; font-size: 14px; font-weight: 600;
            text-decoration: none; transition: background 0.15s;
        }
        .btn-primary:hover { background: var(--primary-h); }
    </style>
</head>
<body>

<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 0 1-8 0"/>
        </svg>
        民大二手交易平台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/orders">我的订单</a>
        <a href="${pageContext.request.contextPath}/messages" class="active">私信</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>私信</h1>
        <p>与买家 / 卖家的沟通记录</p>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert alert-success"><span>✓</span><span><%= successMsg %></span></div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-error"><span>✕</span><span><%= errorMsg %></span></div>
    <% } %>

    <% if (conversations.isEmpty()) { %>
    <div class="empty-box">
        <div class="empty-icon">💬</div>
        <p>还没有私信，去浏览商品并联系卖家吧</p>
        <a class="btn-primary" href="${pageContext.request.contextPath}/product-list">浏览商品</a>
    </div>
    <% } else { %>
    <div class="conv-list">
        <% for (Map<String, Object> conv : conversations) {
            int otherId   = ((Number) conv.get("otherId")).intValue();
            int unread    = ((Number) conv.get("unreadCount")).intValue();
            String otherNickname = (String) conv.get("otherNickname");
            String lastContent   = (String) conv.get("lastContent");
            Object lastTime      = conv.get("lastTime");
            String initial = (otherNickname != null && otherNickname.length() > 0)
                ? String.valueOf(otherNickname.charAt(0)).toUpperCase() : "?";
            String timeStr = "";
            if (lastTime != null) {
                String ts = lastTime.toString();
                timeStr = ts.length() >= 16 ? ts.substring(5, 16) : ts;
            }
        %>
        <a class="conv-item"
           href="${pageContext.request.contextPath}/messages?conversationId=<%= conv.get("conversationId") %>">
            <div class="avatar"><%= initial %></div>
            <div class="conv-info">
                <div class="conv-name"><%= otherNickname %></div>
                <div class="conv-preview"><%= lastContent != null ? lastContent : "" %></div>
            </div>
            <div class="conv-right">
                <div class="conv-time"><%= timeStr %></div>
                <% if (unread > 0) { %>
                <span class="unread-badge"><%= unread > 99 ? "99+" : unread %></span>
                <% } %>
            </div>
        </a>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>
