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
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>消息通知 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header { height: 56px; background: #1677ff; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18); }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a { color: #fff; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 800px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 20px; }
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        .toolbar { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
        .btn { padding: 8px 16px; border-radius: 8px; font-size: 13px; text-decoration: none; border: 1px solid #ddd; background: #fff; color: #555; cursor: pointer; display: inline-block; }
        .btn:hover { border-color: #1677ff; color: #1677ff; }
        .btn-primary { background: #1677ff; color: #fff; border: none; }
        .btn-primary:hover { background: #0e5fd8; color: #fff; }
        .notify-list { display: flex; flex-direction: column; gap: 10px; }
        .notify-item { background: #fff; border-radius: 12px; padding: 16px 20px; box-shadow: 0 2px 12px rgba(0,0,0,0.05); border-left: 4px solid transparent; display: flex; gap: 14px; align-items: flex-start; transition: background 0.2s; }
        .notify-item.unread { border-left-color: #1677ff; background: #f0f7ff; }
        .notify-item.read { border-left-color: #e8e8e8; }
        .notify-dot { width: 8px; height: 8px; border-radius: 50%; background: #1677ff; margin-top: 6px; flex-shrink: 0; }
        .notify-content { flex: 1; line-height: 1.6; font-size: 14px; }
        .notify-time { font-size: 12px; color: #999; margin-top: 6px; }
        .empty { background: #fff; border-radius: 14px; padding: 60px 20px; text-align: center; color: #999; box-shadow: 0 4px 18px rgba(0,0,0,0.05); }
        .empty-icon { font-size: 48px; margin-bottom: 12px; }
        @media (max-width: 600px) { .header { padding: 0 14px; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/orders">我的订单</a>
        <a href="${pageContext.request.contextPath}/messages">私信</a>
        <a href="${pageContext.request.contextPath}/notifications">&#128276; 通知</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-title">&#128276; 消息通知</div>

    <% if (errorMsg != null) { %>
        <div class="msg msg-error">&#10060; <%= errorMsg %></div>
    <% } %>

    <div class="toolbar">
        <span style="font-size:14px;color:#888;">共 <%= notifyList.size() %> 条通知，<span style="color:#1677ff;"><%= unreadCount %></span> 条未读</span>
        <% if (unreadCount > 0) { %>
            <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                <input type="hidden" name="action" value="readAll">
                <button type="submit" class="btn btn-primary">全部标为已读</button>
            </form>
        <% } %>
    </div>

    <% if (notifyList.isEmpty()) { %>
        <div class="empty">
            <div class="empty-icon">&#128276;</div>
            <div>暂无通知</div>
        </div>
    <% } else { %>
        <div class="notify-list">
            <% for (Map<String, Object> n : notifyList) {
                boolean isRead = n.get("isRead") instanceof Boolean ? (Boolean) n.get("isRead") : false;
            %>
            <div class="notify-item <%= isRead ? "read" : "unread" %>">
                <% if (!isRead) { %><div class="notify-dot"></div><% } else { %><div style="width:8px;flex-shrink:0;"></div><% } %>
                <div class="notify-content">
                    <%= n.get("content") %>
                    <div class="notify-time"><%= n.get("createdAt") %></div>
                </div>
                <% if (!isRead) { %>
                    <form action="${pageContext.request.contextPath}/notifications" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="read">
                        <input type="hidden" name="notifyId" value="<%= n.get("notificationId") %>">
                        <button type="submit" class="btn" style="padding:4px 12px;font-size:12px;">标为已读</button>
                    </form>
                <% } %>
            </div>
            <% } %>
        </div>
    <% } %>
</div>

</body>
</html>
