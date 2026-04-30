<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Map<String, Object>> notifyList = (List<Map<String, Object>>) request.getAttribute("notifyList");
    if (notifyList == null) notifyList = new ArrayList<>();
    int unreadCount = request.getAttribute("unreadCount") != null ? ((Number) request.getAttribute("unreadCount")).intValue() : 0;
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>消息通知 — 民大二手交易平台</title>
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
            --radius:     12px;
            --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --shadow:     0 2px 12px rgba(0,0,0,0.06);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body { font-family: var(--font); background: var(--bg); color: var(--text); min-height: 100dvh; }

        .nav {
            height: 56px; background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 28px; position: sticky; top: 0; z-index: 100;
        }
        .nav-brand {
            display: flex; align-items: center; gap: 9px;
            font-size: 16px; font-weight: 700; color: var(--primary); text-decoration: none;
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

        .container { max-width: 700px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 24px; flex-wrap: wrap; gap: 12px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }
        .page-header .meta { font-size: 13.5px; color: var(--text-muted); margin-top: 4px; }

        .alert {
            padding: 11px 14px; border-radius: 8px; font-size: 13.5px;
            margin-bottom: 18px; display: flex; align-items: flex-start; gap: 8px; line-height: 1.5;
        }
        .alert-error { background: var(--error-bg); border: 1px solid var(--error-bd); color: var(--error-tx); }

        .btn {
            padding: 8px 16px; border-radius: 8px; font-size: 13.5px; font-weight: 600;
            font-family: var(--font); cursor: pointer; border: 1px solid var(--border);
            background: var(--surface); color: var(--text-muted); transition: all 0.15s;
            text-decoration: none;
        }
        .btn:hover { border-color: var(--primary); color: var(--primary); }
        .btn-primary { background: var(--primary); color: #fff; border-color: var(--primary); }
        .btn-primary:hover { background: var(--primary-h); color: #fff; }
        .btn-sm { padding: 5px 12px; font-size: 12px; }

        .notify-list { display: flex; flex-direction: column; gap: 8px; }
        .notify-item {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            padding: 14px 18px;
            display: flex; gap: 14px; align-items: flex-start;
            box-shadow: var(--shadow);
            transition: border-color 0.15s;
        }
        .notify-item.unread {
            border-left: 3px solid var(--primary);
            background: #f7fcfb;
        }
        .notify-dot {
            width: 8px; height: 8px; border-radius: 50%;
            background: var(--primary); margin-top: 6px; flex-shrink: 0;
        }
        .notify-dot-placeholder { width: 8px; flex-shrink: 0; }
        .notify-content { flex: 1; font-size: 14px; line-height: 1.7; color: var(--text); }
        .notify-time { font-size: 12px; color: var(--text-muted); margin-top: 5px; }
        .notify-actions { flex-shrink: 0; }

        .empty {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty p { font-size: 14.5px; color: var(--text-muted); }
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
        <a href="${pageContext.request.contextPath}/messages">私信</a>
        <a href="${pageContext.request.contextPath}/notifications" class="active">通知</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <div>
            <h1>消息通知</h1>
            <div class="meta">共 <%= notifyList.size() %> 条通知，<span style="color:var(--primary);font-weight:600;"><%= unreadCount %></span> 条未读</div>
        </div>
        <% if (unreadCount > 0) { %>
        <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
            <input type="hidden" name="action" value="readAll">
            <button type="submit" class="btn btn-primary">全部标为已读</button>
        </form>
        <% } %>
    </div>

    <% if (errorMsg != null) { %>
    <div class="alert alert-error"><span>✕</span><span><%= errorMsg %></span></div>
    <% } %>

    <% if (notifyList.isEmpty()) { %>
    <div class="empty">
        <div class="empty-icon">🔔</div>
        <p>暂无通知</p>
    </div>
    <% } else { %>
    <div class="notify-list">
        <% for (Map<String, Object> n : notifyList) {
            boolean isRead = n.get("isRead") instanceof Boolean ? (Boolean) n.get("isRead") : false;
        %>
        <div class="notify-item <%= isRead ? "read" : "unread" %>">
            <% if (!isRead) { %><div class="notify-dot"></div><% } else { %><div class="notify-dot-placeholder"></div><% } %>
            <div class="notify-content">
                <%= n.get("content") %>
                <div class="notify-time"><%= n.get("createdAt") %></div>
            </div>
            <% if (!isRead) { %>
            <div class="notify-actions">
                <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                    <input type="hidden" name="action" value="read">
                    <input type="hidden" name="notifyId" value="<%= n.get("notificationId") %>">
                    <button type="submit" class="btn btn-sm">已读</button>
                </form>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>
