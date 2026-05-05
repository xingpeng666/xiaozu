<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null || !"ADMIN".equals(loginUser.getRoleCode())) {
        response.sendRedirect(request.getContextPath() + "/login"); return;
    }
    List<Map<String,Object>> productList = (List<Map<String,Object>>) request.getAttribute("productList");
    if (productList == null) productList = new ArrayList<>();
    String tab = (String) request.getAttribute("tab");
    if (tab == null) tab = "pending";
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg"); session.removeAttribute("successMsg");
    String tabPending = "pending".equals(tab) ? " active" : "";
    String tabOnSale  = "on_sale".equals(tab) ? " active" : "";
    String tabReject  = "rejected".equals(tab) ? " active" : "";
    boolean isPending = "pending".equals(tab);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>商品审核 — 民大二手交易平台</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root{
    --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
    --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
    --success-bg:#f0fdf4;--success-bd:#bbf7d0;--success-tx:#15803d;
    --error-bg:#fff1f0;--error-bd:#ffc5c5;--error-tx:#b91c1c;
    --warn:#d97706;--warn-hl:#fef9c3;--warn-bd:#fde68a;
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
.page-header h1{font-size:22px;font-weight:700;margin-bottom:20px}
.alert{padding:11px 14px;border-radius:8px;font-size:13.5px;margin-bottom:18px}
.alert-success{background:var(--success-bg);border:1px solid var(--success-bd);color:var(--success-tx)}
.alert-error{background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
.tab-bar{display:flex;gap:0;border-bottom:2px solid var(--border);margin-bottom:22px}
.tab-bar a{padding:10px 20px;font-size:13.5px;font-weight:600;color:var(--muted);text-decoration:none;border-bottom:2px solid transparent;margin-bottom:-2px;transition:color .15s,border-color .15s}
.tab-bar a:hover{color:var(--primary)}
.tab-bar a.active{color:var(--primary);border-bottom-color:var(--primary)}
.table-wrap{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden}
table{width:100%;border-collapse:collapse}
th,td{padding:12px 14px;text-align:left;border-bottom:1px solid var(--border);font-size:13.5px;vertical-align:middle}
th{background:#fafaf9;font-weight:600;color:var(--muted);white-space:nowrap}
tr:last-child td{border-bottom:none}
tr:hover td{background:#f9f9f7}
.prod-thumb{width:52px;height:52px;object-fit:cover;border-radius:7px;border:1px solid var(--border)}
.btn{padding:6px 13px;border-radius:7px;font-size:12.5px;font-weight:600;font-family:var(--font);border:none;cursor:pointer;transition:background .15s;text-decoration:none;display:inline-block}
.btn-approve{background:var(--primary);color:#fff}
.btn-approve:hover{background:var(--primary-h)}
.btn-reject{background:var(--error-bg);color:var(--error-tx);border:1px solid var(--error-bd)}
.btn-reject:hover{background:#ffe0de}
.empty{text-align:center;padding:60px 20px;background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow)}
.empty p{color:var(--muted);font-size:14.5px;margin-top:12px}
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
        <a href="${pageContext.request.contextPath}/admin/products" class="active">商品审核</a>
        <a href="${pageContext.request.contextPath}/index.jsp">前台首页</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>
<div class="container">
    <div class="page-header"><h1>📦 商品审核</h1></div>
    <% if (errMsg != null) { %><div class="alert alert-error">✕ <%=errMsg%></div><% } %>
    <% if (sucMsg != null) { %><div class="alert alert-success">✓ <%=sucMsg%></div><% } %>

    <div class="tab-bar">
        <a href="?tab=pending" class="<%=tabPending%>">待审核</a>
        <a href="?tab=on_sale" class="<%=tabOnSale%>">已通过</a>
        <a href="?tab=rejected" class="<%=tabReject%>">已驳回</a>
    </div>

    <% if (productList.isEmpty()) { %>
    <div class="empty"><div style="font-size:48px">📦</div><p>暂无商品</p></div>
    <% } else { %>
    <div class="table-wrap">
    <table>
        <thead><tr>
            <th>ID</th><th>封面</th><th>标题</th><th>分类</th><th>价格</th>
            <th>新旧</th><th>发布人</th><th>学号</th><th>时间</th>
            <% if (isPending) { %><th>操作</th><% } %>
        </tr></thead>
        <tbody>
        <% for (Map<String,Object> p : productList) { %>
        <tr>
            <td><%=p.get("productId")%></td>
            <td>
                <% String img = (String) p.get("coverImageUrl"); if (img != null && !img.isEmpty()) { %>
                <img src="<%=img%>" class="prod-thumb" alt="">
                <% } else { %><span style="color:var(--muted)">无图</span><% } %>
            </td>
            <td><%=p.get("title")%></td>
            <td><%=p.get("categoryName") != null ? p.get("categoryName") : "—"%></td>
            <td>&yen;<%=p.get("price")%></td>
            <td><%
                String adminConditionText = "—";
                Object condObj = p.get("conditionLevel");
                if (condObj != null) {
                    String cond = condObj.toString();
                    switch (cond) {
                        case "NEW": adminConditionText = "全新"; break;
                        case "NINETY_NEW": adminConditionText = "九成新"; break;
                        case "EIGHTY_NEW": adminConditionText = "八成新"; break;
                        case "SEVENTY_NEW": adminConditionText = "七成新及以下"; break;
                        default: adminConditionText = cond;
                    }
                }
            %><%= adminConditionText %></td>
            <td><%=p.get("sellerName")%></td>
            <td><%=p.get("sellerNo")%></td>
            <td style="white-space:nowrap;"><small><%=p.get("createdAt") != null ? p.get("createdAt").toString().substring(0,10) : "-"%></small></td>
            <% if (isPending) { %>
            <td style="white-space:nowrap">
                <form method="post" action="${pageContext.request.contextPath}/admin/products" style="display:inline">
                    <input type="hidden" name="productId" value="<%=p.get("productId")%>">
                    <input type="hidden" name="tab" value="pending">
                    <input type="hidden" name="action" value="approve">
                    <button class="btn btn-approve">通过</button>
                </form>
                <form method="post" action="${pageContext.request.contextPath}/admin/products" style="display:inline;margin-left:6px">
                    <input type="hidden" name="productId" value="<%=p.get("productId")%>">
                    <input type="hidden" name="tab" value="pending">
                    <input type="hidden" name="action" value="reject">
                    <button class="btn btn-reject">驳回</button>
                </form>
            </td>
            <% } %>
        </tr>
        <% } %>
        </tbody>
    </table>
    </div>
    <% } %>
</div>
</body>
</html>
