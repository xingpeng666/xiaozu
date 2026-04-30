<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*,com.minzu.entity.Review" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<Review> reviews = (List<Review>) request.getAttribute("reviews");
    if (reviews == null) reviews = new ArrayList<>();
    String view = (String) request.getAttribute("view");
    if (view == null) view = "sent";
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg");
    session.removeAttribute("successMsg");
    String sentActive     = "sent".equals(view)     ? " active" : "";
    String receivedActive = "received".equals(view) ? " active" : "";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的评价 — 民大二手交易平台</title>
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

        .container { max-width: 800px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { margin-bottom: 24px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }

        .alert { padding: 11px 14px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; display: flex; align-items: flex-start; gap: 8px; line-height: 1.5; }
        .alert-error   { background: var(--error-bg);   border: 1px solid var(--error-bd);   color: var(--error-tx); }
        .alert-success { background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); }

        /* Tabs */
        .tabs { display: flex; gap: 4px; margin-bottom: 22px; border-bottom: 1px solid var(--border); padding-bottom: 0; }
        .tabs a {
            font-size: 14px; font-weight: 600; color: var(--text-muted);
            text-decoration: none; padding: 9px 16px;
            border-bottom: 2px solid transparent;
            margin-bottom: -1px; transition: color 0.15s, border-color 0.15s;
        }
        .tabs a:hover { color: var(--primary); }
        .tabs a.active { color: var(--primary); border-bottom-color: var(--primary); }

        /* Review card */
        .review-list { display: flex; flex-direction: column; gap: 10px; }
        .review-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 16px 20px;
        }
        .review-top { display: flex; justify-content: space-between; align-items: flex-start; gap: 10px; margin-bottom: 8px; }
        .review-title { font-size: 14.5px; font-weight: 600; }
        .role-badge {
            display: inline-block; padding: 2px 9px; border-radius: 20px;
            font-size: 12px; font-weight: 600; margin-left: 8px;
            background: var(--primary-hl); color: var(--primary);
        }
        .stars { font-size: 16px; }
        .star-filled { color: #f59e0b; }
        .star-empty  { color: #d1d5db; }
        .review-content { font-size: 14px; color: var(--text); line-height: 1.65; margin-bottom: 8px; }
        .review-meta { font-size: 12px; color: var(--text-muted); }

        .empty {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty p { font-size: 14.5px; color: var(--text-muted); }
    </style>
</head>
<body>

<nav class="nav">
    <a class="nav-brand" href="<%=request.getContextPath()%>/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
            <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
            <line x1="3" y1="6" x2="21" y2="6"/>
            <path d="M16 10a4 4 0 0 1-8 0"/>
        </svg>
        民大二手交易平台
    </a>
    <div class="nav-links">
        <a href="<%=request.getContextPath()%>/orders?type=buy">我的订单</a>
        <a href="<%=request.getContextPath()%>/profile">个人信息</a>
        <a href="<%=request.getContextPath()%>/my-reviews" class="active">我的评价</a>
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>我的评价</h1>
    </div>

    <% if (errMsg != null) { %>
    <div class="alert alert-error"><span>✕</span><span><%=errMsg%></span></div>
    <% } %>
    <% if (sucMsg != null) { %>
    <div class="alert alert-success"><span>✓</span><span><%=sucMsg%></span></div>
    <% } %>

    <div class="tabs">
        <a href="<%=request.getContextPath()%>/review?view=sent" class="<%="sent".equals(view)?"active":""%>">我发出的评价</a>
        <a href="<%=request.getContextPath()%>/review?view=received" class="<%="received".equals(view)?"active":""%>">收到的评价</a>
    </div>

    <% if (reviews.isEmpty()) { %>
    <div class="empty"><p>暂无评价记录</p></div>
    <% } else { %>
    <div class="review-list">
        <% for (Review r : reviews) { %>
        <div class="review-card">
            <div class="review-top">
                <div>
                    <span class="review-title"><%=r.getProductTitle() != null ? r.getProductTitle() : "已删除商品"%></span>
                    <span class="role-badge"><%="BUYER".equals(r.getRole()) ? "买家评价" : "卖家评价"%></span>
                </div>
                <div class="stars">
                    <% for (int i = 0; i < r.getScore(); i++) { %><span class="star-filled">★</span><% } %>
                    <% for (int i = r.getScore(); i < 5; i++) { %><span class="star-empty">★</span><% } %>
                </div>
            </div>
            <% if (r.getContent() != null && !r.getContent().isEmpty()) { %>
            <div class="review-content"><%=r.getContent()%></div>
            <% } %>
            <div class="review-meta">
                <% if ("sent".equals(view)) { %>评价对象：<%=r.getReviewedName()%>
                <% } else { %>评价人：<%=r.getReviewerName()%><% } %>
                &nbsp;&middot;&nbsp;<%=r.getCreatedAt()%>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>
