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
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的纠纷 — 民大二手交易平台</title>
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
            --warn-hl:    #fef3c7;
            --error-bg:   #fff1f0;
            --error-bd:   #ffc5c5;
            --error-tx:   #b91c1c;
            --success-bg: #f0fdf4;
            --success-bd: #bbf7d0;
            --success-tx: #15803d;
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
        .nav-brand {
            display: flex; align-items: center; gap: 9px;
            font-size: 16px; font-weight: 700; color: var(--primary); text-decoration: none;
        }
        .nav-links { display: flex; align-items: center; gap: 4px; }
        .nav-links a {
            font-size: 13.5px; font-weight: 500; color: var(--text-muted);
            text-decoration: none; padding: 6px 11px; border-radius: 7px;
            transition: background 0.15s, color 0.15s;
        }
        .nav-links a:hover { background: var(--primary-hl); color: var(--primary); }
        .nav-links a.active { background: var(--primary-hl); color: var(--primary); }
        .nav-links .btn-logout { margin-left: 6px; padding: 6px 14px; background: var(--primary); color: #fff; border-radius: 7px; }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }

        .container { max-width: 860px; margin: 36px auto; padding: 0 16px 48px; }
        .back-link {
            display: inline-flex; align-items: center; gap: 5px;
            font-size: 13.5px; color: var(--text-muted); text-decoration: none;
            margin-bottom: 18px; transition: color 0.15s;
        }
        .back-link:hover { color: var(--primary); }
        .page-header h1 { font-size: 22px; font-weight: 700; margin-bottom: 22px; }

        .alert { padding: 11px 14px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; display: flex; align-items: flex-start; gap: 8px; line-height: 1.5; }
        .alert-error   { background: var(--error-bg);   border: 1px solid var(--error-bd);   color: var(--error-tx); }
        .alert-success { background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); }

        .dispute-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 18px 22px; margin-bottom: 12px;
        }
        .card-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 10px; margin-bottom: 12px; }
        .card-title { font-size: 15px; font-weight: 700; }
        .badge {
            display: inline-block; padding: 3px 11px; border-radius: 20px;
            font-size: 12px; font-weight: 600; white-space: nowrap;
        }
        .badge-pending { background: var(--warn-hl);    color: var(--warn); }
        .badge-refund  { background: var(--success-bg); color: var(--success-tx); }
        .badge-release { background: var(--primary-hl); color: var(--primary); }

        .info-row { display: flex; gap: 20px; flex-wrap: wrap; font-size: 13px; color: var(--text-muted); margin-bottom: 12px; }
        .info-row strong { color: var(--text); font-weight: 600; }

        .reason-box {
            background: #fffbf5; border-left: 3px solid var(--warn);
            padding: 10px 14px; border-radius: 0 8px 8px 0;
            font-size: 13.5px; line-height: 1.6; color: var(--text);
            margin-bottom: 8px;
        }
        .admin-note {
            background: var(--primary-hl); border-left: 3px solid var(--primary);
            padding: 10px 14px; border-radius: 0 8px 8px 0;
            font-size: 13.5px; line-height: 1.6; color: var(--primary);
        }

        .empty {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty p { font-size: 14.5px; color: var(--text-muted); margin-bottom: 6px; }
        .empty small { font-size: 13px; color: var(--text-muted); }
    </style>
</head>
<body>

<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 0 1-8 0"/>
        </svg>
        民大二手交易平台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/product-list">首页</a>
        <a href="${pageContext.request.contextPath}/order?action=list">我的订单</a>
        <a href="${pageContext.request.contextPath}/dispute?action=list" class="active">我的纠纷</a>
        <a href="${pageContext.request.contextPath}/notifications">通知</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <a class="back-link" href="${pageContext.request.contextPath}/order?action=list">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
        返回我的订单
    </a>
    <div class="page-header"><h1>我的纠纷</h1></div>

    <% if (successMsg != null) { %>
    <div class="alert alert-success"><span>✓</span><span><%= successMsg %></span></div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="alert alert-error"><span>✕</span><span><%= errorMsg %></span></div>
    <% } %>

    <% if (disputeList.isEmpty()) { %>
    <div class="empty">
        <div class="empty-icon">🎉</div>
        <p>暂无纠纷记录</p>
        <small>如有交易问题，可在订单页发起纠纷</small>
    </div>
    <% } else { %>
        <% for (Map<String, Object> d : disputeList) {
            String status = (String) d.get("status");
        %>
        <div class="dispute-card">
            <div class="card-top">
                <div class="card-title"><%= d.get("productTitle") != null ? d.get("productTitle") : "商品已删除" %></div>
                <% if ("PENDING".equals(status)) { %>
                    <span class="badge badge-pending">待处理</span>
                <% } else if ("REFUND".equals(status)) { %>
                    <span class="badge badge-refund">已退款</span>
                <% } else { %>
                    <span class="badge badge-release">已放行</span>
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
            <div class="reason-box">纠纷原因：<%= d.get("reason") %></div>
            <% if (d.get("adminNote") != null && !d.get("adminNote").toString().isEmpty()) { %>
            <div class="admin-note">管理员备注：<%= d.get("adminNote") %></div>
            <% } %>
        </div>
        <% } %>
    <% } %>
</div>

</body>
</html>
