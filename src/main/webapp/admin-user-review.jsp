<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.minzu.entity.User" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户审核 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
    :root{
        --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
        --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
        --warn:#d97706;--warn-hl:#fef9c3;--warn-bd:#fde68a;
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
    .container{max-width:1100px;margin:36px auto;padding:0 16px 48px}
    .page-header{margin-bottom:6px}
    .page-header h1{font-size:22px;font-weight:700}
    .page-header p{font-size:13.5px;color:var(--muted);margin-top:4px;margin-bottom:20px}
    .alert{padding:11px 14px;border-radius:8px;font-size:13.5px;margin-bottom:18px}
    .alert-success{background:var(--success-bg);border:1px solid var(--success-bd);color:var(--success-tx)}
    .alert-error{background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
    .table-wrap{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden}
    table{width:100%;border-collapse:collapse}
    th,td{padding:13px 14px;text-align:left;border-bottom:1px solid var(--border);font-size:13.5px}
    th{background:#fafaf9;font-weight:600;color:var(--muted)}
    tr:last-child td{border-bottom:none}
    tr:hover td{background:#f9f9f7}
    .status-badge{display:inline-block;padding:2px 10px;border-radius:20px;font-size:12px;font-weight:600;background:var(--warn-hl);color:var(--warn);border:1px solid var(--warn-bd)}
    .btn{padding:6px 14px;border-radius:7px;font-size:13px;font-weight:600;font-family:var(--font);cursor:pointer;text-decoration:none;display:inline-block;border:none;transition:background .15s}
    .btn-approve{background:var(--primary);color:#fff;margin-right:6px}
    .btn-approve:hover{background:var(--primary-h)}
    .btn-reject{background:var(--error-bg);color:var(--error-tx);border:1px solid var(--error-bd)}
    .btn-reject:hover{background:#ffe0de}
    .empty{text-align:center;padding:60px 20px}
    .empty p{font-size:14.5px;color:var(--muted);margin-top:10px}
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
        <a href="${pageContext.request.contextPath}/admin/users" class="active">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出登录</a>
    </div>
</nav>
<div class="container">
    <div class="page-header">
        <h1>👤 用户审核</h1>
        <p>管理员可对新注册用户进行审核，通过后用户即可正常登录系统。</p>
    </div>
    <%
        String successMsg = (String) session.getAttribute("successMsg");
        if (successMsg != null) session.removeAttribute("successMsg");
        String sessionErrorMsg = (String) session.getAttribute("errorMsg");
        if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
        List<User> userList = (List<User>) request.getAttribute("userList");
    %>
    <% if (successMsg != null) { %><div class="alert alert-success"><%= successMsg %></div><% } %>
    <% if (sessionErrorMsg != null) { %><div class="alert alert-error"><%= sessionErrorMsg %></div>
    <% } else if (request.getAttribute("errorMsg") != null) { %><div class="alert alert-error"><%= request.getAttribute("errorMsg") %></div><% } %>

    <% if (userList == null || userList.isEmpty()) { %>
    <div class="table-wrap"><div class="empty"><div style="font-size:40px">🎉</div><p>当前没有待审核用户。</p></div></div>
    <% } else { %>
    <div class="table-wrap">
    <table>
        <thead><tr>
            <th>用户ID</th><th>学号/工号</th><th>真实姓名</th>
            <th>昵称</th><th>角色</th><th>状态</th><th>操作</th>
        </tr></thead>
        <tbody>
        <% for (User u : userList) { %>
        <tr>
            <td><%= u.getUserId() %></td>
            <td><%= u.getStudentOrStaffNo() %></td>
            <td><%= u.getRealName() %></td>
            <td><%= u.getNickname() == null ? "-" : u.getNickname() %></td>
            <td><%= u.getRoleCode() %></td>
            <td><span class="status-badge"><%= u.getAccountStatus() %></span></td>
            <td>
                <a class="btn btn-approve"
                   href="${pageContext.request.contextPath}/admin/approve-user?userId=<%= u.getUserId() %>"
                   onclick="return confirm('确定审核通过该用户吗？')">通过</a>
                <a class="btn btn-reject"
                   href="${pageContext.request.contextPath}/admin/reject-user?userId=<%= u.getUserId() %>"
                   onclick="return confirm('确定将该用户设为禁用吗？')">禁用</a>
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
