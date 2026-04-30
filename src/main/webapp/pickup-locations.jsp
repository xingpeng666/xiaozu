<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
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
    List<Map<String, Object>> locations = (List<Map<String, Object>>) request.getAttribute("locationList");
    if (locations == null) locations = new ArrayList<>();
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园自提点 — 民大二手交易平台</title>
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
            --warn:       #d97706;
            --warn-hl:    #fef9c3;
            --warn-bd:    #fde68a;
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
        .nav-brand { display: flex; align-items: center; gap: 9px; font-size: 16px; font-weight: 700; color: var(--primary); text-decoration: none; }
        .nav-links { display: flex; align-items: center; gap: 4px; }
        .nav-links a { font-size: 13.5px; font-weight: 500; color: var(--text-muted); text-decoration: none; padding: 6px 11px; border-radius: 7px; transition: background 0.15s, color 0.15s; position: relative; }
        .nav-links a:hover { background: var(--primary-hl); color: var(--primary); }
        .nav-links .btn-logout { margin-left: 6px; padding: 6px 14px; background: var(--primary); color: #fff; border-radius: 7px; }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }
        .notify-badge { position: absolute; top: 2px; right: 2px; min-width: 16px; height: 16px; background: #ef4444; color: #fff; border-radius: 8px; font-size: 10px; font-weight: 700; display: flex; align-items: center; justify-content: center; padding: 0 4px; }

        .container { max-width: 900px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { margin-bottom: 8px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }
        .page-subtitle { font-size: 13.5px; color: var(--text-muted); margin-bottom: 28px; }

        .alert-error { background: var(--error-bg); border: 1px solid var(--error-bd); color: var(--error-tx); padding: 11px 14px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; }

        .location-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(260px, 1fr)); gap: 16px; }
        .location-card {
            background: var(--surface); border: 1px solid var(--border);
            border-left: 4px solid var(--primary);
            border-radius: var(--radius); padding: 22px;
            box-shadow: var(--shadow);
            transition: transform 0.18s, box-shadow 0.18s;
        }
        .location-card:hover { transform: translateY(-2px); box-shadow: 0 6px 22px rgba(0,0,0,0.09); }
        .loc-icon { font-size: 26px; margin-bottom: 10px; }
        .loc-name { font-size: 16px; font-weight: 700; color: var(--primary); margin-bottom: 7px; }
        .loc-address { font-size: 13.5px; color: var(--text); margin-bottom: 6px; display: flex; align-items: flex-start; gap: 5px; }
        .loc-desc { font-size: 13px; color: var(--text-muted); line-height: 1.65; }

        .tips-box {
            margin-top: 28px; background: var(--warn-hl);
            border: 1px solid var(--warn-bd); border-radius: var(--radius);
            padding: 16px 20px; font-size: 13.5px; color: #92400e; line-height: 1.7;
        }
        .tips-box strong { color: var(--warn); }

        .empty {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty p { font-size: 14.5px; color: var(--text-muted); margin-top: 14px; }

        @media (max-width: 600px) { .location-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        民大二手交易平台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <% if (loginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
            <a href="${pageContext.request.contextPath}/orders">我的订单</a>
            <a href="${pageContext.request.contextPath}/messages">私信</a>
            <a href="${pageContext.request.contextPath}/notifications" style="position:relative;">
                通知
                <% if (unreadNotifyCount > 0) { %>
                <span class="notify-badge"><%= unreadNotifyCount %></span>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login">登录</a>
        <% } %>
    </div>
</nav>

<div class="container">
    <div class="page-header"><h1>📍 校园自提点位</h1></div>
    <p class="page-subtitle">以下是中央民族大学校内推荐的自提交易地点，方便买卖双方线下安全交易</p>

    <% if (errorMsg != null) { %>
    <div class="alert-error">✕ <%= errorMsg %></div>
    <% } %>

    <% if (locations.isEmpty()) { %>
    <div class="empty">
        <div style="font-size:48px;">📍</div>
        <p>暂无自提点信息</p>
    </div>
    <% } else { %>
    <div class="location-grid">
        <% for (Map<String, Object> loc : locations) { %>
        <div class="location-card">
            <div class="loc-icon">📌</div>
            <div class="loc-name"><%= loc.get("name") %></div>
            <div class="loc-address">
                <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="flex-shrink:0;margin-top:2px;"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <%= loc.get("address") %>
            </div>
            <% if (loc.get("description") != null && !((String) loc.get("description")).isEmpty()) { %>
            <div class="loc-desc"><%= loc.get("description") %></div>
            <% } %>
        </div>
        <% } %>
    </div>
    <% } %>

    <div class="tips-box">
        <strong>💡 安全交易小贴士：</strong>
        建议选择校内人流量大的公共区域进行面交，尽量避开偿僻地点。交易前确认商品状况，当面清点金额。如遇到问题可联系平台客服。
    </div>
</div>

</body>
</html>
