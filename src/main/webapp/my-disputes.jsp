<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }

    List<Map<String, Object>> disputeList = (List<Map<String, Object>>) request.getAttribute("disputeList");
    if (disputeList == null) disputeList = new ArrayList<>();

    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
    String errorMsg = (String) session.getAttribute("errorMsg");
    if (errorMsg != null) { request.setAttribute("errorMsg", errorMsg); session.removeAttribute("errorMsg"); }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的纠纷 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header { height: 56px; background: #1677ff; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18); }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a { color: #fff; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 960px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 20px; }
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        .card { background: #fff; border-radius: 14px; box-shadow: 0 4px 18px rgba(0,0,0,0.06); margin-bottom: 16px; padding: 20px 24px; }
        .card-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 12px; }
        .card-title { font-size: 15px; font-weight: bold; }
        .badge { display: inline-block; padding: 3px 12px; border-radius: 999px; font-size: 12px; color: #fff; }
        .badge-pending  { background: #fa8c16; }
        .badge-refund   { background: #52c41a; }
        .badge-release  { background: #1677ff; }
        .info-row { display: flex; gap: 24px; flex-wrap: wrap; font-size: 13px; color: #666; margin-bottom: 8px; }
        .info-row span strong { color: #333; }
        .reason-box { background: #fafafa; border-left: 3px solid #fa8c16; padding: 10px 14px; border-radius: 0 8px 8px 0; font-size: 13px; margin-top: 10px; }
        .admin-note { background: #f0f5ff; border-left: 3px solid #1677ff; padding: 10px 14px; border-radius: 0 8px 8px 0; font-size: 13px; margin-top: 8px; color: #1677ff; }
        .empty { background: #fff; border-radius: 14px; padding: 60px 20px; text-align: center; color: #999; box-shadow: 0 4px 18px rgba(0,0,0,0.05); }
        .back-link { display: inline-block; margin-bottom: 20px; color: #1677ff; text-decoration: none; font-size: 14px; }
        .back-link:hover { text-decoration: underline; }
        @media (max-width: 600px) { .card { padding: 14px 14px; } .info-row { gap: 12px; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/product-list">首页</a>
        <a href="${pageContext.request.contextPath}/order?action=list">我的订单</a>
        <a href="${pageContext.request.contextPath}/dispute?action=list">我的纠纷</a>
        <a href="${pageContext.request.contextPath}/notifications">通知</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <a href="${pageContext.request.contextPath}/order?action=list" class="back-link">&#8592; 返回我的订单</a>
    <div class="page-title">&#9878; 我的纠纷</div>

    <% if (successMsg != null) { %>
        <div class="msg msg-success">&#9989; <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">&#10060; <%= errorMsg %></div>
    <% } %>

    <% if (disputeList.isEmpty()) { %>
        <div class="empty">
            <div style="font-size:48px;margin-bottom:16px;">&#127881;</div>
            <div>暂无纠纷记录</div>
            <div style="margin-top:8px;font-size:13px;">如有交易问题，可在订单页发起纠纷</div>
        </div>
    <% } else { %>
        <% for (Map<String, Object> d : disputeList) {
            String status = (String) d.get("status");
        %>
        <div class="card">
            <div class="card-header">
                <div class="card-title">&#128230; <%= d.get("productTitle") != null ? d.get("productTitle") : "商品已删除" %></div>
                <% if ("PENDING".equals(status)) { %>
                    <span class="badge badge-pending">&#8987; 待处理</span>
                <% } else if ("REFUND".equals(status)) { %>
                    <span class="badge badge-refund">&#10004; 已退款</span>
                <% } else { %>
                    <span class="badge badge-release">&#8594; 已放行</span>
                <% } %>
            </div>
            <div class="info-row">
                <span>纠纷编号：<strong>#<%= d.get("disputeId") %></strong></span>
                <span>订单编号：<strong>#<%= d.get("orderId") %></strong></span>
                <span>提交时间：<strong><%= d.get("createdAt") != null ? d.get("createdAt").toString().substring(0,16) : "-" %></strong></span>
                <% if (d.get("resolvedAt") != null) { %>
                <span>处理时间：<strong><%= d.get("resolvedAt").toString().substring(0,16) %></strong></span>
                <% } %>
            </div>
            <div class="reason-box">&#128226; 纠纷原因：<%= d.get("reason") %></div>
            <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
            <div class="admin-note">&#128196; 管理员备注：<%= d.get("adminNote") %></div>
            <% } %>
        </div>
        <% } %>
    <% } %>
</div>

</body>
</html>
