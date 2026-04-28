<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");

    // 查询未读通知数
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

    // 从 Servlet 获取取货点列表
    List<Map<String, Object>> locations = (List<Map<String, Object>>) request.getAttribute("locationList");
    if (locations == null) locations = new ArrayList<>();

    // 读取错误消息
    String errorMsg = (String) request.getAttribute("errorMsg");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>校园自提点 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header { height: 56px; background: #1677ff; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18); }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a { color: #fff; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 900px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 8px; }
        .page-subtitle { font-size: 14px; color: #888; margin-bottom: 24px; }
        .location-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 18px; }
        .location-card {
            background: #fff; border-radius: 14px; padding: 24px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.06);
            border-left: 5px solid #1677ff;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .location-card:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.09); }
        .location-card .loc-name { font-size: 18px; font-weight: bold; color: #1677ff; margin-bottom: 8px; }
        .location-card .loc-address { font-size: 14px; color: #555; margin-bottom: 8px; }
        .location-card .loc-desc { font-size: 13px; color: #999; line-height: 1.6; }
        .location-card .loc-icon { font-size: 28px; margin-bottom: 10px; }
        .tips-box {
            margin-top: 32px; background: #fffbe6; border: 1px solid #ffe58f; border-radius: 12px;
            padding: 18px 22px; font-size: 14px; color: #8c6d14;
        }
        .tips-box strong { color: #d48806; }
        @media (max-width: 600px) { .location-grid { grid-template-columns: 1fr; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <% if (loginUser != null) { %>
            <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
            <a href="${pageContext.request.contextPath}/orders">我的订单</a>
            <a href="${pageContext.request.contextPath}/messages">私信</a>
            <a href="${pageContext.request.contextPath}/notifications" style="position:relative;">
                &#128276; 通知
                <% if (unreadNotifyCount > 0) { %>
                <span style="position:absolute;top:-6px;right:-10px;background:#ff4d4f;color:#fff;border-radius:10px;padding:1px 6px;font-size:11px;line-height:16px;min-width:18px;text-align:center;"><%= unreadNotifyCount %></span>
                <% } %>
            </a>
            <a href="${pageContext.request.contextPath}/logout">退出</a>
        <% } else { %>
            <a href="${pageContext.request.contextPath}/login">登录</a>
        <% } %>
    </div>
</div>

<div class="container">
    <div class="page-title">&#128205; 校园自提点位</div>
    <div class="page-subtitle">以下是中央民族大学校内推荐的自提交易地点，方便买卖双方线下安全交易</div>

    <% if (errorMsg != null) { %>
        <div style="background:#fff2f0;color:#cf1322;border:1px solid #ffccc7;border-radius:8px;padding:12px 16px;margin-bottom:16px;font-size:14px;">
            &#10060; <%= errorMsg %>
        </div>
    <% } %>

    <% if (locations.isEmpty()) { %>
        <div style="background:#fff;border-radius:14px;padding:60px 20px;text-align:center;color:#999;box-shadow:0 4px 18px rgba(0,0,0,0.05);">
            <div style="font-size:48px;margin-bottom:12px;">&#128205;</div>
            <div>暂无自提点信息</div>
        </div>
    <% } else { %>
        <div class="location-grid">
            <% for (Map<String, Object> loc : locations) { %>
            <div class="location-card">
                <div class="loc-icon">&#128204;</div>
                <div class="loc-name"><%= loc.get("name") %></div>
                <div class="loc-address">&#128205; <%= loc.get("address") %></div>
                <% if (loc.get("description") != null && !((String) loc.get("description")).isEmpty()) { %>
                    <div class="loc-desc"><%= loc.get("description") %></div>
                <% } %>
            </div>
            <% } %>
        </div>
    <% } %>

    <div class="tips-box">
        <strong>&#128161; 安全交易小贴士：</strong>
        建议选择校内人流量大的公共区域进行面交，尽量避开偏僻地点。交易前确认商品状况，当面清点金额。如遇到问题可联系平台客服。
    </div>
</div>

</body>
</html>
