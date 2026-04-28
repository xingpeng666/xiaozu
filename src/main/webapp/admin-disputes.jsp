<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

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
    <title>纠纷管理 - 民大二手交易平台</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: Arial, sans-serif; background: #f5f7fa; color: #333; }
        .header { height: 56px; background: #1677ff; color: #fff; display: flex; align-items: center; justify-content: space-between; padding: 0 24px; box-shadow: 0 2px 8px rgba(22,119,255,0.18); }
        .header .logo { font-size: 18px; font-weight: bold; }
        .header .nav a { color: #fff; text-decoration: none; margin-left: 14px; font-size: 14px; padding: 6px 12px; border-radius: 6px; }
        .header .nav a:hover { background: rgba(255,255,255,0.16); }
        .container { max-width: 1200px; margin: 28px auto; padding: 0 16px 40px; }
        .page-title { font-size: 22px; font-weight: bold; margin-bottom: 20px; }
        .msg { padding: 12px 16px; border-radius: 8px; margin-bottom: 16px; font-size: 14px; }
        .msg-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .msg-error   { background: #fff2f0; color: #cf1322; border: 1px solid #ffccc7; }
        table { width: 100%; border-collapse: collapse; background: #fff; border-radius: 14px; overflow: hidden; box-shadow: 0 4px 18px rgba(0,0,0,0.06); }
        th, td { padding: 14px 16px; text-align: left; border-bottom: 1px solid #f0f0f0; font-size: 14px; vertical-align: top; }
        th { background: #fafafa; font-weight: bold; color: #555; white-space: nowrap; }
        tr:hover td { background: #fafcff; }
        .badge { display: inline-block; padding: 3px 10px; border-radius: 999px; font-size: 12px; color: #fff; }
        .badge-pending  { background: #fa8c16; }
        .badge-refund   { background: #52c41a; }
        .badge-release  { background: #1677ff; }
        .btn { padding: 8px 16px; border-radius: 8px; font-size: 13px; border: none; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-sm { padding: 6px 14px; font-size: 12px; }
        .btn-success { background: #f6ffed; color: #389e0d; border: 1px solid #b7eb8f; }
        .btn-success:hover { background: #d9f7be; }
        .btn-primary { background: #e6f4ff; color: #1677ff; border: 1px solid #91caff; }
        .btn-primary:hover { background: #bae0ff; }
        .empty { background: #fff; border-radius: 14px; padding: 60px 20px; text-align: center; color: #999; box-shadow: 0 4px 18px rgba(0,0,0,0.05); }
        .note-input { width: 180px; padding: 5px 8px; border: 1px solid #ddd; border-radius: 6px; font-size: 12px; }
        .action-form { display: inline-flex; gap: 6px; align-items: center; flex-wrap: wrap; }
        @media (max-width: 900px) { th, td { padding: 10px 10px; font-size: 12px; } .note-input { width: 120px; } }
    </style>
</head>
<body>

<div class="header">
    <div class="logo">&#127979; 民大二手交易平台 - 管理后台</div>
    <div class="nav">
        <a href="${pageContext.request.contextPath}/admin/dashboard">统计面板</a>
        <a href="${pageContext.request.contextPath}/admin/users">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/report">举报管理</a>
        <a href="${pageContext.request.contextPath}/dispute?action=admin">纠纷管理</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout">退出</a>
    </div>
</div>

<div class="container">
    <div class="page-title">&#9878; 订单纠纷管理</div>

    <% if (successMsg != null) { %>
        <div class="msg msg-success">&#9989; <%= successMsg %></div>
    <% } %>
    <% if (errorMsg != null) { %>
        <div class="msg msg-error">&#10060; <%= errorMsg %></div>
    <% } %>

    <% if (disputeList.isEmpty()) { %>
        <div class="empty">&#127881; 暂无待处理纠纷</div>
    <% } else { %>
    <table>
        <thead>
            <tr>
                <th>纠纷ID</th>
                <th>订单ID</th>
                <th>商品</th>
                <th>买家</th>
                <th>卖家</th>
                <th>纠纷原因</th>
                <th>状态</th>
                <th>提交时间</th>
                <th>操作</th>
            </tr>
        </thead>
        <tbody>
            <% for (Map<String, Object> d : disputeList) {
                String status = (String) d.get("status");
            %>
            <tr>
                <td>#<%= d.get("disputeId") %></td>
                <td>#<%= d.get("orderId") %></td>
                <td><%= d.get("productTitle") != null ? d.get("productTitle") : "-" %></td>
                <td><%= d.get("buyerName") != null ? d.get("buyerName") : "-" %></td>
                <td><%= d.get("sellerName") != null ? d.get("sellerName") : "-" %></td>
                <td style="max-width:200px;"><%= d.get("reason") %>
                    <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
                        <br><small style="color:#888;">管理员备注：<%= d.get("adminNote") %></small>
                    <% } %>
                </td>
                <td>
                    <% if ("PENDING".equals(status)) { %>
                        <span class="badge badge-pending">待处理</span>
                    <% } else if ("REFUND".equals(status)) { %>
                        <span class="badge badge-refund">已退款</span>
                    <% } else { %>
                        <span class="badge badge-release">已放行</span>
                    <% } %>
                </td>
                <td style="white-space:nowrap;"><%= d.get("createdAt") != null ? d.get("createdAt").toString().substring(0,16) : "-" %></td>
                <td>
                    <% if ("PENDING".equals(status)) { %>
                    <form action="${pageContext.request.contextPath}/dispute" method="post" style="margin:0;">
                        <input type="hidden" name="action" value="resolve">
                        <input type="hidden" name="disputeId" value="<%= d.get("disputeId") %>">
                        <div class="action-form">
                            <input type="text" name="adminNote" class="note-input" placeholder="备注（选填）">
                            <button type="submit" name="result" value="REFUND" class="btn btn-success btn-sm"
                                onclick="return confirm('确定裁决退款？订单将退款，商品重新上架。');">&#10004; 退款</button>
                            <button type="submit" name="result" value="RELEASE" class="btn btn-primary btn-sm"
                                onclick="return confirm('确定放行？订单将正常完成。');">&#8594; 放行</button>
                        </div>
                    </form>
                    <% } else { %>
                        <span style="color:#999;font-size:12px;">已处理</span>
                    <% } %>
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
    <% } %>
</div>

</body>
</html>
