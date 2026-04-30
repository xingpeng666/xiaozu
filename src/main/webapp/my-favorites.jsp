<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<Product> favoriteList = (List<Product>) request.getAttribute("favoriteList");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>我的收藏 — 民大二手交易平台</title>
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
            --danger-hl:  #fee2e2;
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

        .container { max-width: 1080px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { display: flex; justify-content: space-between; align-items: baseline; margin-bottom: 24px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }
        .page-header .count { font-size: 13.5px; color: var(--text-muted); }

        .alert-success { background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); padding: 11px 14px; border-radius: 8px; font-size: 13.5px; margin-bottom: 18px; }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: 18px;
        }
        .product-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
            overflow: hidden; display: flex; flex-direction: column;
            transition: box-shadow 0.18s, transform 0.15s;
        }
        .product-card:hover { box-shadow: 0 6px 24px rgba(0,0,0,0.1); transform: translateY(-2px); }

        .card-cover { position: relative; }
        .card-cover img { width: 100%; height: 170px; object-fit: cover; display: block; background: #f0f0ee; }
        .no-cover { width: 100%; height: 170px; background: #f0f0ee; display: flex; align-items: center; justify-content: center; font-size: 36px; color: #ccc; }
        .sold-mask {
            position: absolute; inset: 0;
            background: rgba(0,0,0,0.42);
            display: flex; align-items: center; justify-content: center;
            color: #fff; font-size: 18px; font-weight: 700; letter-spacing: 2px;
            pointer-events: none;
        }

        .card-body { padding: 12px 14px; flex: 1; display: flex; flex-direction: column; gap: 4px; }
        .card-title {
            font-size: 14.5px; font-weight: 600;
            overflow: hidden; text-overflow: ellipsis; white-space: nowrap;
        }
        .card-price { font-size: 17px; font-weight: 700; color: var(--danger); }
        .card-price .orig {
            font-size: 12px; font-weight: 400; color: #b0b0b0;
            text-decoration: line-through; margin-left: 6px;
        }
        .card-meta { font-size: 12px; color: var(--text-muted); margin-top: 2px; }

        .card-actions {
            padding: 10px 14px; border-top: 1px solid var(--border);
            display: flex; gap: 8px;
        }
        .btn {
            display: inline-block; padding: 7px 14px; border-radius: 7px;
            text-decoration: none; font-size: 13px; font-weight: 600;
            font-family: var(--font); border: 1.5px solid var(--border);
            background: var(--surface); color: var(--text-muted);
            cursor: pointer; transition: all 0.15s;
        }
        .btn:hover { border-color: var(--primary); color: var(--primary); }
        .btn-unfav { background: var(--danger-hl); color: var(--danger); border-color: #fca5a5; }
        .btn-unfav:hover { background: #fecaca; }
        .btn:disabled { opacity: 0.5; cursor: not-allowed; }

        .empty {
            text-align: center; padding: 72px 20px;
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty-icon { font-size: 48px; margin-bottom: 14px; }
        .empty p { font-size: 14.5px; color: var(--text-muted); margin-bottom: 20px; }
        .btn-primary {
            display: inline-block; padding: 10px 24px;
            background: var(--primary); color: #fff;
            border-radius: 8px; font-size: 14px; font-weight: 600;
            text-decoration: none; transition: background 0.15s;
        }
        .btn-primary:hover { background: var(--primary-h); }
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
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
        <a href="${pageContext.request.contextPath}/product-list">浏览商品</a>
        <a href="${pageContext.request.contextPath}/my-favorites" class="active">我的收藏</a>
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/messages">私信</a>
        <a href="${pageContext.request.contextPath}/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>我的收藏</h1>
        <span class="count">共 <%= favoriteList != null ? favoriteList.size() : 0 %> 件商品</span>
    </div>

    <% if (successMsg != null) { %>
    <div class="alert-success"><%= successMsg %></div>
    <% } %>

    <% if (favoriteList == null || favoriteList.isEmpty()) { %>
    <div class="empty">
        <div class="empty-icon">❤️</div>
        <p>还没有收藏任何商品</p>
        <a href="${pageContext.request.contextPath}/product-list" class="btn-primary">去浏览商品</a>
    </div>
    <% } else { %>
    <div class="product-grid">
        <% for (Product p : favoriteList) {
            boolean isSold    = "SOLD".equals(p.getProductStatus());
            boolean isOffline = "OFF_SHELF".equals(p.getProductStatus());
        %>
        <div class="product-card" id="card-<%= p.getProductId() %>">
            <div class="card-cover">
                <% if (p.getCoverImageUrl() != null && !p.getCoverImageUrl().isEmpty()) { %>
                    <img src="<%= p.getCoverImageUrl() %>" alt="<%= p.getTitle() %>" loading="lazy">
                <% } else { %>
                    <div class="no-cover">📦</div>
                <% } %>
                <% if (isSold) { %><div class="sold-mask">已售出</div><% } %>
                <% if (isOffline) { %><div class="sold-mask" style="background:rgba(0,0,0,0.3);">已下架</div><% } %>
            </div>
            <div class="card-body">
                <div class="card-title" title="<%= p.getTitle() %>"><%= p.getTitle() %></div>
                <div class="card-price">
                    &yen;<%= p.getPrice() %>
                    <% if (p.getOriginalPrice() != null) { %><span class="orig">&yen;<%= p.getOriginalPrice() %></span><% } %>
                </div>
                <div class="card-meta">
                    <%= p.getCategoryName() != null ? p.getCategoryName() : "未分类" %>
                    &nbsp;&middot;&nbsp;<%= p.getSellerName() != null ? p.getSellerName() : "未知" %>
                </div>
            </div>
            <div class="card-actions">
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= p.getProductId() %>" class="btn">查看详情</a>
                <button class="btn btn-unfav" onclick="unfavorite(<%= p.getProductId() %>, this)">取消收藏</button>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>

<script>
function unfavorite(productId, btn) {
    if (!confirm('确定取消收藏吗？')) return;
    btn.disabled = true;
    btn.textContent = '处理中…';
    fetch('${pageContext.request.contextPath}/favorite', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: 'productId=' + encodeURIComponent(productId)
    })
    .then(function(r){ return r.json(); })
    .then(function(data){
        if (data.success) {
            var card = document.getElementById('card-' + productId);
            if (card) {
                card.style.transition = 'opacity 0.3s, transform 0.3s';
                card.style.opacity = '0';
                card.style.transform = 'scale(0.95)';
                setTimeout(function(){ card.remove(); }, 320);
            }
        } else {
            alert(data.msg || '操作失败');
            btn.disabled = false;
            btn.textContent = '取消收藏';
        }
    })
    .catch(function(){
        alert('网络错误，请重试');
        btn.disabled = false;
        btn.textContent = '取消收藏';
    });
}
</script>

</body>
</html>
