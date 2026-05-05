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
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>纠纷管理 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root{
            --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
            --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
            --warn:#d97706;--warn-hl:#fef9c3;
            --success-bg:#f0fdf4;--success-bd:#bbf7d0;--success-tx:#15803d;
            --error-bg:#fff1f0;--error-bd:#ffc5c5;--error-tx:#b91c1c;
            --radius:12px;--font:'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --shadow:0 2px 12px rgba(0,0,0,0.06);
        }
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        html{-webkit-font-smoothing:antialiased}
        body{font-family:var(--font);background:var(--bg);color:var(--text);min-height:100dvh}
        .nav{height:56px;background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 28px;position:sticky;top:0;z-index:100}
        .nav-brand{display:flex;align-items:center;gap:9px;font-size:16px;font-weight:700;color:var(--primary);text-decoration:none}
        .nav-links{display:flex;align-items:center;gap:4px}
        .nav-links a{font-size:13.5px;font-weight:500;color:var(--muted);text-decoration:none;padding:6px 11px;border-radius:7px;transition:background .15s,color .15s}
        .nav-links a:hover,.nav-links a.active{background:var(--primary-hl);color:var(--primary)}
        .nav-links .btn-logout{margin-left:6px;padding:6px 14px;background:var(--primary);color:#fff;border-radius:7px}
        .nav-links .btn-logout:hover{background:var(--primary-h);color:#fff}
        .container{max-width:1200px;margin:36px auto;padding:0 16px 48px}
        .page-header h1{font-size:22px;font-weight:700;margin-bottom:22px}
        .alert{padding:11px 14px;border-radius:8px;font-size:13.5px;margin-bottom:18px}
        .alert-success{background:var(--success-bg);border:1px solid var(--success-bd);color:var(--success-tx)}
        .alert-error{background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
        .table-wrap{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden}
        table{width:100%;border-collapse:collapse}
        th,td{padding:12px 14px;text-align:left;border-bottom:1px solid var(--border);font-size:13.5px;vertical-align:top}
        th{background:#fafaf9;font-weight:600;color:var(--muted);white-space:nowrap}
        tr:last-child td{border-bottom:none}
        tr:hover td{background:#f9f9f7}
        .badge{display:inline-block;padding:2px 10px;border-radius:20px;font-size:12px;font-weight:600}
        .badge-pending{background:var(--warn-hl);color:var(--warn)}
        .badge-refund{background:var(--success-bg);color:var(--success-tx)}
        .badge-release{background:var(--primary-hl);color:var(--primary)}
        .note-input{padding:5px 8px;border:1.5px solid var(--border);border-radius:6px;font-size:12px;font-family:var(--font);width:150px;outline:none;transition:border-color .15s}
        .note-input:focus{border-color:var(--primary)}
        .action-form{display:inline-flex;gap:6px;align-items:center;flex-wrap:wrap}
        .btn{padding:6px 13px;border-radius:7px;font-size:12.5px;font-weight:600;font-family:var(--font);border:none;cursor:pointer;transition:background .15s}
        .btn-refund{background:var(--success-bg);color:var(--success-tx);border:1px solid var(--success-bd)}
        .btn-refund:hover{background:#dcfce7}
        .btn-release{background:var(--primary-hl);color:var(--primary);border:1px solid #a7d9d4}
        .btn-release:hover{background:#b8e0db}
        .empty{text-align:center;padding:72px 20px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow)}
        .empty p{font-size:14.5px;color:var(--muted);margin-top:14px}
        @media(max-width:900px){th,td{padding:10px 10px;font-size:12px}.note-input{width:100px}}
    </style>
</head>
<body>
<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        民大二手 · 管理后台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/admin/dashboard">统计面板</a>
        <a href="${pageContext.request.contextPath}/admin/user-review">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/report">举报管理</a>
        <a href="${pageContext.request.contextPath}/dispute?action=admin" class="active">纠纷管理</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>
<div class="container">
    <div class="page-header"><h1>⚖️ 订单纠纷管理</h1></div>
    <% if (successMsg != null) { %><div class="alert alert-success">✓ <%= successMsg %></div><% } %>
    <% if (errorMsg != null) { %><div class="alert alert-error">✕ <%= errorMsg %></div><% } %>

    <% if (disputeList.isEmpty()) { %>
    <div class="empty"><div style="font-size:48px;">🎉</div><p>暂无待处理纠纷</p></div>
    <% } else { %>
    <div class="table-wrap">
    <table>
        <thead><tr>
            <th>纠纷ID</th><th>订单ID</th><th>商品</th><th>买家</th><th>卖家</th>
            <th>纠纷原因</th><th>状态</th><th>提交时间</th><th>操作</th>
        </tr></thead>
        <tbody>
        <% for (Map<String, Object> d : disputeList) { String status = (String) d.get("status"); %>
        <tr>
            <td>#<%= d.get("disputeId") %></td>
            <td>#<%= d.get("orderId") %></td>
            <td><%= d.get("productTitle") != null ? d.get("productTitle") : "-" %></td>
            <td><%= d.get("buyerName") != null ? d.get("buyerName") : "-" %></td>
            <td><%= d.get("sellerName") != null ? d.get("sellerName") : "-" %></td>
            <td style="max-width:200px;">
                <%= d.get("reason") %>
                <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
                <br><small style="color:var(--muted)">备注：<%= d.get("adminNote") %></small>
                <% } %>
            </td>
            <td>
                <% if ("PENDING".equals(status)) { %><span class="badge badge-pending">待处理</span>
                <% } else if ("REFUND".equals(status)) { %><span class="badge badge-refund">已退款</span>
                <% } else { %><span class="badge badge-release">已放行</span><% } %>
            </td>
            <td style="white-space:nowrap;"><%= d.get("createdAt") != null ? d.get("createdAt").toString().substring(0,16) : "-" %></td>
            <td>
                <% if ("PENDING".equals(status)) { %>
                <form action="${pageContext.request.contextPath}/dispute" method="post" style="margin:0">
                    <input type="hidden" name="action" value="resolve">
                    <input type="hidden" name="disputeId" value="<%= d.get("disputeId") %>">
                    <div class="action-form">
                        <input type="text" name="adminNote" class="note-input" placeholder="备注（选填）">
                        <button type="submit" name="result" value="REFUND" class="btn btn-refund" onclick="return confirm('确定裁决退款？')"> ✔ 退款</button>
                        <button type="submit" name="result" value="RELEASE" class="btn btn-release" onclick="return confirm('确定放行？')">→ 放行</button>
                    </div>
                </form>
                <% } else { %><span style="color:var(--muted);font-size:12px;">已处理</span><% } %>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>
</div>
</body>
</html>
