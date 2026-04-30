<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    List<Map<String, Object>> reportList = (List<Map<String, Object>>) request.getAttribute("reportList");
    if (reportList == null) reportList = new ArrayList<>();
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
    <title>举报管理 — 民大二手交易平台</title>
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
    .badge-pending{background:var(--warn-hl);color:var(--warn);border:1px solid var(--warn-bd)}
    .badge-approved{background:#f1f5f9;color:#475569;border:1px solid #e2e8f0}
    .badge-rejected{background:var(--success-bg);color:var(--success-tx);border:1px solid var(--success-bd)}
    .badge-closed{background:#f5f5f5;color:#a3a3a3;border:1px solid #e5e5e5}
    .btn{padding:6px 13px;border-radius:7px;font-size:12.5px;font-weight:600;font-family:var(--font);border:none;cursor:pointer;transition:background .15s;text-decoration:none;display:inline-block}
    .btn-takedown{background:var(--error-bg);color:var(--error-tx);border:1px solid var(--error-bd)}
    .btn-takedown:hover{background:#ffe0de}
    .btn-dismiss{background:#f5f5f5;color:var(--muted);border:1px solid #e5e5e5}
    .btn-dismiss:hover{background:#e5e5e5}
    .prod-link{color:var(--primary);text-decoration:none;font-weight:500}
    .prod-link:hover{text-decoration:underline}
    .empty{text-align:center;padding:72px 20px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow)}
    .empty p{color:var(--muted);font-size:14.5px;margin-top:14px}
    @media(max-width:768px){th,td{padding:10px 12px;font-size:12px}}
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
        <a href="${pageContext.request.contextPath}/admin/users">用户审核</a>
        <a href="${pageContext.request.contextPath}/admin/products">商品审核</a>
        <a href="${pageContext.request.contextPath}/report" class="active">举报管理</a>
        <a href="${pageContext.request.contextPath}/dispute?action=admin">纠纷管理</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>
<div class="container">
    <div class="page-header"><h1>🔔 举报管理</h1></div>
    <% if (successMsg != null) { %><div class="alert alert-success">✓ <%= successMsg %></div><% } %>
    <% if (errorMsg != null) { %><div class="alert alert-error">✕ <%= errorMsg %></div><% } %>

    <% if (reportList.isEmpty()) { %>
    <div class="empty"><div style="font-size:48px">📬</div><p>暂无举报记录</p></div>
    <% } else { %>
    <div class="table-wrap">
    <table>
        <thead><tr>
            <th>举报ID</th><th>举报人</th><th>商品</th><th>商品状态</th>
            <th>举报原因</th><th>状态</th><th>举报时间</th><th>处理时间</th><th>操作</th>
        </tr></thead>
        <tbody>
        <%
        for (Map<String, Object> r : reportList) {
            String st = (String) r.get("status");
            String ps = (String) r.get("publishStatus");
        %>
        <tr>
            <td>#<%= r.get("reportId") %></td>
            <td><%= r.get("reporterName") != null ? r.get("reporterName") : "未知" %></td>
            <td>
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= r.get("productId") %>" target="_blank" class="prod-link">
                    <%= r.get("productTitle") != null ? r.get("productTitle") : "商品已删除" %>
                </a>
            </td>
            <td><%= ps != null ? ps : "-" %></td>
            <td>
                <%= r.get("reason") != null ? r.get("reason") : "-" %>
                <% if (r.get("reportDetail") != null && !r.get("reportDetail").toString().isEmpty()) { %>
                <br><small style="color:var(--muted)"><%= r.get("reportDetail") %></small>
                <% } %>
            </td>
            <td>
                <% if ("PENDING".equals(st)) { %><span class="badge badge-pending">待处理</span>
                <% } else if ("APPROVED".equals(st)) { %><span class="badge badge-approved">已下架</span>
                <% } else if ("REJECTED".equals(st)) { %><span class="badge badge-rejected">已驳回</span>
                <% } else { %><span class="badge badge-closed">已关闭</span><% } %>
            </td>
            <td style="white-space:nowrap"><%= r.get("createdAt") != null ? r.get("createdAt").toString().substring(0,16) : "-" %></td>
            <td style="white-space:nowrap"><%= r.get("handledAt") != null ? r.get("handledAt").toString().substring(0,16) : "-" %></td>
            <td>
                <% if ("PENDING".equals(st)) { %>
                    <% if (!"OFF_SHELF".equals(ps) && !"SOLD".equals(ps)) { %>
                    <form action="${pageContext.request.contextPath}/report" method="post" style="display:inline" onsubmit="return confirm('确定下架该商品？');">
                        <input type="hidden" name="action" value="takedown">
                        <input type="hidden" name="productId" value="<%= r.get("productId") %>">
                        <input type="hidden" name="reportId" value="<%= r.get("reportId") %>">
                        <button class="btn btn-takedown">↓ 下架</button>
                    </form>
                    <% } %>
                    <form action="${pageContext.request.contextPath}/report" method="post" style="display:inline;margin-left:6px" onsubmit="return confirm('确定驳回该举报？');">
                        <input type="hidden" name="action" value="dismiss">
                        <input type="hidden" name="reportId" value="<%= r.get("reportId") %>">
                        <button class="btn btn-dismiss">× 驳回</button>
                    </form>
                <% } else if ("OFF_SHELF".equals(ps) || "APPROVED".equals(st)) { %>
                    <span style="color:var(--muted);font-size:12px">已下架</span>
                <% } else { %>
                    <span style="color:var(--muted);font-size:12px">—</span>
                <% } %>
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
