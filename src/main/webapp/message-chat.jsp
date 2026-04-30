<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Message" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    int me = loginUser.getUserId();
    int otherId = (Integer) request.getAttribute("otherId");
    String otherNickname = (String) request.getAttribute("otherNickname");
    Map<String, Object> product = (Map<String, Object>) request.getAttribute("product");
    List<Message> chatList = (List<Message>) request.getAttribute("chatList");
    Long conversationId = (Long) request.getAttribute("conversationId");
    Object pidObj = request.getAttribute("productId");
    Integer productId = null;
    if (pidObj instanceof Long) productId = ((Long) pidObj).intValue();
    else if (pidObj instanceof Integer) productId = (Integer) pidObj;
    String successMsg = (String) session.getAttribute("successMsg");
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = (String) request.getAttribute("errorMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    if (errorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= otherNickname %> — 私信</title>
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
            --danger:     #dc2626;
            --success-bg: #f0fdf4;
            --success-bd: #bbf7d0;
            --success-tx: #15803d;
            --error-bg:   #fff1f0;
            --error-bd:   #ffc5c5;
            --error-tx:   #b91c1c;
            --radius:     12px;
            --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body {
            font-family: var(--font);
            background: var(--bg); color: var(--text);
            display: flex; flex-direction: column; height: 100dvh;
        }

        /* NAV */
        .nav {
            height: 52px; background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex; align-items: center; justify-content: space-between;
            padding: 0 18px; flex-shrink: 0;
        }
        .nav-left { display: flex; align-items: center; gap: 10px; }
        .back-link {
            display: flex; align-items: center; gap: 4px;
            font-size: 13.5px; color: var(--text-muted); text-decoration: none;
            padding: 5px 9px; border-radius: 7px; transition: background 0.15s, color 0.15s;
        }
        .back-link:hover { background: var(--primary-hl); color: var(--primary); }
        .chat-title { font-size: 15px; font-weight: 700; }
        .nav-brand {
            display: flex; align-items: center; gap: 7px;
            font-size: 14px; font-weight: 700; color: var(--primary); text-decoration: none;
        }

        /* ALERTS */
        .alert-bar {
            padding: 9px 16px; font-size: 13.5px; text-align: center; flex-shrink: 0;
        }
        .alert-bar.success { background: var(--success-bg); border-bottom: 1px solid var(--success-bd); color: var(--success-tx); }
        .alert-bar.error   { background: var(--error-bg);   border-bottom: 1px solid var(--error-bd);   color: var(--error-tx); }

        /* PRODUCT BAR */
        .product-bar {
            background: var(--surface); border-bottom: 1px solid var(--border);
            padding: 10px 16px; display: flex; align-items: center; gap: 12px;
            flex-shrink: 0;
        }
        .product-bar img { width: 42px; height: 42px; border-radius: 8px; object-fit: cover; }
        .product-bar-ph { width: 42px; height: 42px; border-radius: 8px; background: #f0f0ee; display: flex; align-items: center; justify-content: center; font-size: 20px; }
        .product-bar-info { flex: 1; min-width: 0; }
        .product-bar-title { font-size: 13px; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .product-bar-price { font-size: 13px; color: var(--danger); margin-top: 2px; }
        .product-bar-link {
            font-size: 12px; font-weight: 600; color: var(--primary);
            text-decoration: none; border: 1px solid var(--primary-hl);
            padding: 4px 10px; border-radius: 20px;
            transition: background 0.15s;
        }
        .product-bar-link:hover { background: var(--primary-hl); }

        /* CHAT BODY */
        .chat-body {
            flex: 1; overflow-y: auto; padding: 16px;
            display: flex; flex-direction: column; gap: 12px;
        }
        .empty-chat { margin: auto; text-align: center; color: var(--text-muted); font-size: 14px; padding: 40px 0; }

        .msg-row { display: flex; gap: 8px; }
        .msg-row.mine { flex-direction: row-reverse; }

        .avatar {
            width: 34px; height: 34px; border-radius: 50%;
            background: var(--text-muted); color: #fff; flex-shrink: 0;
            display: flex; align-items: center; justify-content: center;
            font-size: 13px; font-weight: 700;
        }
        .msg-row.mine .avatar { background: var(--primary); }

        .bubble-wrap { display: flex; flex-direction: column; max-width: 68%; }
        .msg-row.mine .bubble-wrap { align-items: flex-end; }

        .bubble {
            padding: 9px 13px; border-radius: 14px;
            font-size: 14px; line-height: 1.6; word-break: break-word;
            background: var(--surface); border: 1px solid var(--border);
            box-shadow: 0 1px 4px rgba(0,0,0,0.05);
        }
        .msg-row.mine .bubble {
            background: var(--primary); color: #fff; border-color: var(--primary);
        }
        .bubble-time { font-size: 11px; color: #b0b0b0; margin-top: 3px; padding: 0 4px; }

        /* INPUT */
        .chat-input-area {
            background: var(--surface); border-top: 1px solid var(--border);
            padding: 12px 16px; flex-shrink: 0;
        }
        .chat-input-area form { display: flex; gap: 10px; align-items: flex-end; }
        .chat-input-area textarea {
            flex: 1; padding: 10px 12px;
            border: 1.5px solid var(--border); border-radius: 10px;
            font-size: 14px; font-family: var(--font);
            resize: none; outline: none;
            min-height: 42px; max-height: 120px; line-height: 1.5;
            transition: border-color 0.18s, box-shadow 0.18s;
        }
        .chat-input-area textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(11,110,99,0.1);
        }
        .send-btn {
            background: var(--primary); color: #fff; border: none;
            padding: 10px 20px; border-radius: 10px; font-size: 14px; font-weight: 600;
            font-family: var(--font); cursor: pointer; height: 42px; white-space: nowrap;
            transition: background 0.15s;
        }
        .send-btn:hover { background: var(--primary-h); }
    </style>
</head>
<body>

<div class="nav">
    <div class="nav-left">
        <a class="back-link" href="${pageContext.request.contextPath}/messages">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
            返回
        </a>
        <span class="chat-title"><%= otherNickname %></span>
    </div>
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 0 1-8 0"/>
        </svg>
        民大二手
    </a>
</div>

<% if (successMsg != null) { %>
<div class="alert-bar success">✓ <%= successMsg %></div>
<% } %>
<% if (errorMsg != null) { %>
<div class="alert-bar error">✕ <%= errorMsg %></div>
<% } %>

<% if (product != null) { %>
<div class="product-bar">
    <% String coverUrl = (String) product.get("coverUrl"); %>
    <% if (coverUrl != null && !coverUrl.isEmpty()) { %>
        <img src="<%= coverUrl %>" alt="">
    <% } else { %>
        <div class="product-bar-ph">📦</div>
    <% } %>
    <div class="product-bar-info">
        <div class="product-bar-title"><%= product.get("title") %></div>
        <div class="product-bar-price">&yen;<%= product.get("price") %></div>
    </div>
    <a class="product-bar-link" href="${pageContext.request.contextPath}/product-detail?id=<%= product.get("productId") %>">查看商品</a>
</div>
<% } %>

<div class="chat-body" id="chatBody">
    <% if (chatList == null || chatList.isEmpty()) { %>
    <div class="empty-chat">还没有消息，发一条开始聊天吧 👋</div>
    <% } else {
        for (Message msg : chatList) {
            boolean isMine = msg.getSenderId() == me;
            String initial = msg.getSenderNickname() != null && msg.getSenderNickname().length() > 0
                ? String.valueOf(msg.getSenderNickname().charAt(0)).toUpperCase() : "?";
            String timeStr = "";
            if (msg.getCreatedAt() != null) timeStr = msg.getCreatedAt().toString().substring(0, 16);
    %>
    <div class="msg-row <%= isMine ? "mine" : "" %>">
        <div class="avatar"><%= initial %></div>
        <div class="bubble-wrap">
            <div class="bubble"><%= msg.getContent() %></div>
            <div class="bubble-time"><%= timeStr %></div>
        </div>
    </div>
    <% } } %>
</div>

<div class="chat-input-area">
    <form method="post" action="${pageContext.request.contextPath}/messages" id="msgForm"
          onsubmit="var v=document.getElementById('msgInput').value.trim(); if(!v){alert('消息内容不能为空');return false;}">
        <% if (conversationId != null) { %>
            <input type="hidden" name="conversationId" value="<%= conversationId %>">
        <% } %>
        <input type="hidden" name="receiverId" value="<%= otherId %>">
        <% if (productId != null) { %>
            <input type="hidden" name="productId" value="<%= productId %>">
        <% } %>
        <textarea name="content" id="msgInput" placeholder="输入消息…" rows="1"
                  onkeydown="handleKey(event)"></textarea>
        <button type="submit" class="send-btn">发送</button>
    </form>
</div>

<script>
    (function() { var b = document.getElementById('chatBody'); if (b) b.scrollTop = b.scrollHeight; })();
    function handleKey(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            if (!document.getElementById('msgInput').value.trim()) { alert('消息内容不能为空'); return; }
            document.getElementById('msgForm').submit();
        }
    }
    document.getElementById('msgInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = Math.min(this.scrollHeight, 120) + 'px';
    });
</script>

</body>
</html>
