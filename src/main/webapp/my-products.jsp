<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%!
    private String statusText(String status) {
        if ("ON_SALE".equals(status))        return "在售";
        if ("OFF_SHELF".equals(status))      return "已下架";
        if ("SOLD".equals(status))           return "已售出";
        if ("PENDING_REVIEW".equals(status)) return "待审核";
        if ("REJECTED".equals(status))       return "已驳回";
        return status == null ? "-" : status;
    }
%>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
    List<Product> productList = (List<Product>) request.getAttribute("productList");
    String statusFilter = (String) request.getAttribute("statusFilter");
    if (statusFilter == null) statusFilter = "";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的商品 — 民大二手交易平台</title>
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
            --danger:     #dc2626;
            --warn:       #d97706;
            --success-tx: #15803d;
            --success-bg: #f0fdf4;
            --success-bd: #bbf7d0;
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

        .nav { height: 56px; background: var(--surface); border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; padding: 0 28px; position: sticky; top: 0; z-index: 100; }
        .nav-brand { display: flex; align-items: center; gap: 9px; font-size: 16px; font-weight: 700; color: var(--primary); text-decoration: none; }
        .nav-links { display: flex; align-items: center; gap: 4px; }
        .nav-links a { font-size: 13.5px; font-weight: 500; color: var(--text-muted); text-decoration: none; padding: 6px 11px; border-radius: 7px; transition: background 0.15s, color 0.15s; }
        .nav-links a:hover { background: var(--primary-hl); color: var(--primary); }
        .nav-links a.active { background: var(--primary-hl); color: var(--primary); }
        .nav-links .btn-logout { margin-left: 6px; padding: 6px 14px; background: var(--primary); color: #fff; border-radius: 7px; }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }

        .container { max-width: 1100px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 22px; flex-wrap: wrap; gap: 12px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }
        .btn-publish { display: inline-block; padding: 9px 20px; background: var(--primary); color: #fff; border-radius: 8px; font-size: 14px; font-weight: 600; text-decoration: none; transition: background 0.15s; }
        .btn-publish:hover { background: var(--primary-h); }

        .alert { padding: 11px 14px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; }
        .alert-success { background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); }
        .alert-error   { background: var(--error-bg);   border: 1px solid var(--error-bd);   color: var(--error-tx); }

        .filter-bar { display: flex; gap: 6px; margin-bottom: 22px; flex-wrap: wrap; }
        .filter-bar a { padding: 5px 14px; border-radius: 20px; text-decoration: none; font-size: 13px; font-weight: 500; background: var(--surface); color: var(--text-muted); border: 1.5px solid var(--border); transition: all 0.15s; }
        .filter-bar a:hover { border-color: var(--primary); color: var(--primary); }
        .filter-bar a.active { background: var(--primary); color: #fff; border-color: var(--primary); }

        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 18px; }
        .product-card { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); box-shadow: var(--shadow); overflow: hidden; display: flex; flex-direction: column; }
        .product-card img { width: 100%; height: 172px; object-fit: cover; background: #f0f0ee; display: block; }
        .no-cover { width: 100%; height: 172px; background: #f0f0ee; display: flex; align-items: center; justify-content: center; font-size: 32px; color: #ccc; }
        .card-body { padding: 13px 14px; flex: 1; display: flex; flex-direction: column; gap: 5px; }
        .card-title { font-size: 14.5px; font-weight: 600; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .card-price { font-size: 17px; font-weight: 700; color: var(--danger); }
        .card-price .orig { font-size: 12px; font-weight: 400; color: #b0b0b0; text-decoration: line-through; margin-left: 6px; }
        .card-meta { font-size: 12px; color: var(--text-muted); }
        .status-badge { display: inline-block; padding: 2px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; margin-bottom: 2px; }
        .s-ON_SALE        { background: var(--success-bg); color: var(--success-tx); border: 1px solid var(--success-bd); }
        .s-OFF_SHELF      { background: #f5f5f5; color: #737373; border: 1px solid #e5e5e5; }
        .s-SOLD           { background: #fef9c3; color: #854d0e; border: 1px solid #fde68a; }
        .s-PENDING_REVIEW { background: var(--primary-hl); color: var(--primary); border: 1px solid #a7d9d4; }
        .s-REJECTED       { background: var(--error-bg); color: var(--error-tx); border: 1px solid var(--error-bd); }
        .card-actions { padding: 10px 14px; border-top: 1px solid var(--border); display: flex; gap: 7px; flex-wrap: wrap; }
        .btn { display: inline-block; padding: 6px 13px; border-radius: 7px; font-size: 13px; font-weight: 600; font-family: var(--font); border: 1.5px solid var(--border); background: var(--surface); color: var(--text-muted); cursor: pointer; text-decoration: none; transition: all 0.15s; }
        .btn:hover { border-color: var(--primary); color: var(--primary); }
        .btn-warn { background: #fff7ed; color: var(--warn); border-color: #fed7aa; }
        .btn-warn:hover { background: #ffedd5; }
        .btn-success { background: var(--success-bg); color: var(--success-tx); border-color: var(--success-bd); }
        .btn-success:hover { background: #dcfce7; }
        .empty { text-align: center; padding: 72px 20px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); box-shadow: var(--shadow); }
        .empty p { font-size: 14.5px; color: var(--text-muted); margin: 14px 0 22px; }
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
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>
        <a href="${pageContext.request.contextPath}/my-products" class="active">我的商品</a>
        <% if ("ADMIN".equals(loginUser.getRoleCode())) { %>
        <a href="${pageContext.request.contextPath}/admin/user-review">用户审核</a>
        <% } %>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>我的商品</h1>
        <a href="${pageContext.request.contextPath}/publish-product" class="btn-publish">发布商品</a>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert alert-success"><%= successMsg %></div>
    <% } %>
    <% if (sessionErrorMsg != null) { %>
    <div class="alert alert-error"><%= sessionErrorMsg %></div>
    <% } else if (request.getAttribute("errorMsg") != null) { %>
    <div class="alert alert-error"><%= request.getAttribute("errorMsg") %></div>
    <% } %>

    <div class="filter-bar">
        <a href="${pageContext.request.contextPath}/my-products" class="<%= "".equals(statusFilter)?"active":"" %>">全部</a>
        <a href="${pageContext.request.contextPath}/my-products?status=ON_SALE" class="<%= "ON_SALE".equals(statusFilter)?"active":"" %>">在售</a>
        <a href="${pageContext.request.contextPath}/my-products?status=OFF_SHELF" class="<%= "OFF_SHELF".equals(statusFilter)?"active":"" %>">已下架</a>
        <a href="${pageContext.request.contextPath}/my-products?status=SOLD" class="<%= "SOLD".equals(statusFilter)?"active":"" %>">已售出</a>
        <a href="${pageContext.request.contextPath}/my-products?status=PENDING_REVIEW" class="<%= "PENDING_REVIEW".equals(statusFilter)?"active":"" %>">待审核</a>
        <a href="${pageContext.request.contextPath}/my-products?status=REJECTED" class="<%= "REJECTED".equals(statusFilter)?"active":"" %>">已驳回</a>
    </div>

    <% if (productList == null || productList.isEmpty()) { %>
    <div class="empty">
        <div style="font-size:48px;">📦</div>
        <p>你还没有发布任何商品</p>
        <a href="${pageContext.request.contextPath}/publish-product" class="btn-publish">立即发布</a>
    </div>
    <% } else { %>
    <div class="product-grid">
        <% for (Product p : productList) { %>
        <div class="product-card">
            <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" loading="lazy">
            <% } else { %>
                <div class="no-cover">📷</div>
            <% } %>
            <div class="card-body">
                <div class="card-title" title="<%= p.getTitle() %>"><%= p.getTitle() %></div>
                <div><span class="status-badge s-<%= p.getProductStatus() %>"><%= statusText(p.getProductStatus()) %></span></div>
                <div class="card-price">&yen;<%= p.getPrice() %>
                    <% if (p.getOriginalPrice() != null) { %><span class="orig">&yen;<%= p.getOriginalPrice() %></span><% } %>
                </div>
                <div class="card-meta">
                    <%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %>
                    &middot; 浏览 <%= p.getViewCount() %> 次
                    &middot; <%= p.getCreatedAt() != null ? p.getCreatedAt().toString().substring(0,10) : "" %>
                </div>
            </div>
            <div class="card-actions">
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="btn">查看详情</a>
                <% if (!"SOLD".equals(p.getProductStatus())) { %>
                <a href="${pageContext.request.contextPath}/edit-product?id=<%= p.getProductId() %>" class="btn">编辑</a>
                <% } %>
                <% if ("ON_SALE".equals(p.getProductStatus())) { %>
                <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                    <input type="hidden" name="action" value="offshelf">
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    <button type="submit" class="btn btn-warn" onclick="return confirm('确定下架该商品吗？');">  下架</button>
                </form>
                <% } else if ("OFF_SHELF".equals(p.getProductStatus())) { %>
                <form method="post" action="${pageContext.request.contextPath}/my-products" style="margin:0;">
                    <input type="hidden" name="action" value="onshelf">
                    <input type="hidden" name="productId" value="<%= p.getProductId() %>">
                    <button type="submit" class="btn btn-success" onclick="return confirm('确定重新上架该商品吗？');"> 重新上架</button>
                </form>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

</body>
</html>
