<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.BrowseHistory" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    List<BrowseHistory> historyList = (List<BrowseHistory>) request.getAttribute("historyList");
    SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>浏览历史 - 民大二手交易平台</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;500;600;700;800&family=Noto+Sans+SC:wght@400;500;600;700&display=swap" rel="stylesheet">
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: { 50: '#f0fdf4', 100: '#dcfce7', 200: '#bbf7d0', 300: '#86efac', 400: '#4ade80', 500: '#22c55e', 600: '#16a34a', 700: '#15803d', 800: '#166534', 900: '#14532d' },
                        accent: { DEFAULT: '#f97316', hover: '#ea580c' },
                        surface: { DEFAULT: '#fafaf9', raised: '#ffffff' },
                        ink: { primary: '#1c1917', secondary: '#44403c', muted: '#78716c', faint: '#a8a29e' }
                    },
                    fontFamily: {
                        display: ['Outfit', 'sans-serif'],
                        body: ['Noto Sans SC', 'sans-serif']
                    }
                }
            }
        }
    </script>
    <style>
        .hover-lift { transition: transform 0.3s cubic-bezier(0.34, 1.56, 0.64, 1), box-shadow 0.3s ease; }
        .hover-lift:hover { transform: translateY(-4px); box-shadow: 0 20px 40px rgba(0,0,0,0.12); }
        .btn-press { transition: transform 0.15s ease; }
        .btn-press:active { transform: scale(0.97); }
        .img-zoom { transition: transform 0.5s cubic-bezier(0.34, 1.56, 0.64, 1); }
        .img-zoom:hover { transform: scale(1.1); }
        .card-enter {
            animation: cardIn 0.5s cubic-bezier(0.34, 1.56, 0.64, 1) both;
        }
        @keyframes cardIn {
            from { opacity: 0; transform: translateY(20px) scale(0.95); }
            to { opacity: 1; transform: translateY(0) scale(1); }
        }
        .price-tag {
            position: relative; overflow: hidden;
        }
        .price-tag::after {
            content: '';
            position: absolute;
            inset: 0;
            background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
            transform: translateX(-100%);
            animation: shimmer 2s infinite;
        }
        @keyframes shimmer {
            100% { transform: translateX(100%); }
        }
        .sold-overlay {
            backdrop-filter: blur(2px);
        }
        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press, .img-zoom, .card-enter { animation: none; transition: none; }
            .hover-lift:hover, .img-zoom:hover { transform: none; }
            .btn-press:active { transform: none; }
            .price-tag::after { animation: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-gradient-to-br from-stone-50 via-brand-50/20 to-stone-100">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="browse-history"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-6xl mx-auto px-4 py-8">
    <!-- 标题区 -->
    <div class="flex items-center justify-between mb-8">
        <div>
            <h1 class="font-display text-3xl font-bold text-ink-primary flex items-center gap-3">
                <span class="w-10 h-10 bg-gradient-to-br from-blue-400 to-blue-600 rounded-xl flex items-center justify-center shadow-lg shadow-blue-500/20">
                    <svg class="w-5 h-5 text-white" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <polyline points="12 6 12 12 16 14"/>
                    </svg>
                </span>
                浏览历史
            </h1>
            <p class="text-ink-muted mt-1">共 <span class="text-ink-primary font-medium"><%= historyList != null ? historyList.size() : 0 %></span> 条记录</p>
        </div>
        <% if (historyList != null && !historyList.isEmpty()) { %>
        <form action="${pageContext.request.contextPath}/browse-history" method="post" onsubmit="return confirm('确定清空所有浏览历史吗？');">
            <input type="hidden" name="action" value="clear">
            <button type="submit" class="px-4 py-2 bg-red-50 text-red-600 text-sm font-medium rounded-xl hover:bg-red-100 transition-colors btn-press border border-red-200/50 flex items-center gap-2">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <polyline points="3 6 5 6 21 6"/>
                    <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
                </svg>
                清空历史
            </button>
        </form>
        <% } %>
    </div>

    <% if (historyList == null || historyList.isEmpty()) { %>
    <!-- 空状态 -->
    <div class="bg-surface-raised border border-stone-200 rounded-2xl p-16 text-center shadow-sm">
        <div class="w-16 h-16 mx-auto mb-4 bg-blue-50 rounded-full flex items-center justify-center">
            <svg class="w-8 h-8 text-blue-400" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
            </svg>
        </div>
        <p class="text-ink-muted text-sm mb-4">还没有浏览记录</p>
        <a href="${pageContext.request.contextPath}/product-list" class="inline-flex items-center gap-2 px-5 py-2.5 bg-gradient-to-r from-brand-500 to-brand-600 text-white font-medium rounded-lg hover:from-brand-600 hover:to-brand-700 transition-all btn-press shadow-lg shadow-brand-500/20">
            去浏览商品
        </a>
    </div>
    <% } else { %>
    <!-- 商品网格 -->
    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-5">
        <%
            int delay = 0;
            for (BrowseHistory bh : historyList) {
                boolean isSold = "SOLD".equals(bh.getProductStatus());
                boolean isOffline = "OFF_SHELF".equals(bh.getProductStatus());
                String delayStyle = "animation-delay: " + String.format("%.2f", delay * 0.05) + "s";
                delay++;
        %>
        <div class="card-enter bg-surface-raised border border-stone-200 rounded-2xl overflow-hidden hover-lift flex flex-col group <%= (isSold || isOffline) ? "opacity-75" : "" %>" style="<%= delayStyle %>">
            <div class="relative overflow-hidden">
                <% if (bh.getCoverImageUrl() != null && !bh.getCoverImageUrl().isEmpty()) { %>
                    <img src="<%= bh.getCoverImageUrl() %>" alt="<%= bh.getProductTitle() %>" class="w-full h-40 object-cover <%= (isSold || isOffline) ? "" : "img-zoom" %>" loading="lazy">
                <% } else { %>
                    <div class="w-full h-40 bg-stone-100 flex items-center justify-center">
                        <svg class="w-10 h-10 text-stone-300" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="3" width="18" height="18" rx="2" ry="2"/>
                            <circle cx="8.5" cy="8.5" r="1.5"/>
                            <polyline points="21 15 16 10 5 21"/>
                        </svg>
                    </div>
                <% } %>
                <% if (isSold) { %>
                <div class="sold-overlay absolute inset-0 bg-black/40 flex items-center justify-center">
                    <span class="px-4 py-2 bg-black/60 text-white font-bold text-sm rounded-full backdrop-blur-sm">已售出</span>
                </div>
                <% } %>
                <% if (isOffline) { %>
                <div class="sold-overlay absolute inset-0 bg-black/30 flex items-center justify-center">
                    <span class="px-4 py-2 bg-black/60 text-white font-bold text-sm rounded-full backdrop-blur-sm">已下架</span>
                </div>
                <% } %>
                <!-- 浏览时间标签 -->
                <div class="absolute top-3 right-3">
                    <span class="px-2.5 py-1 bg-black/60 backdrop-blur-sm text-white text-xs font-medium rounded-full"><%= bh.getBrowseTime() != null ? sdf.format(bh.getBrowseTime()) : "" %></span>
                </div>
            </div>
            <div class="p-4 flex-1 flex flex-col">
                <h3 class="text-sm font-medium <% if (isSold || isOffline) { %>text-ink-secondary<% } else { %>text-ink-primary<% } %> truncate <% if (!isSold && !isOffline) { %>group-hover:text-brand-600 transition-colors<% } %>" title="<%= bh.getProductTitle() %>"><%= bh.getProductTitle() %></h3>
                <div class="mt-2">
                    <% if (isSold || isOffline) { %>
                        <span class="text-lg font-bold text-ink-muted">&yen;<%= bh.getPrice() %></span>
                    <% } else { %>
                        <span class="price-tag text-xl font-bold text-red-600 bg-red-50 px-2 py-0.5 rounded inline-block">&yen;<%= bh.getPrice() %></span>
                    <% } %>
                </div>
            </div>
            <div class="px-4 py-3 border-t border-stone-100">
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= bh.getProductId() %>" class="block w-full py-2 <% if (isSold || isOffline) { %>bg-stone-100 text-ink-muted<% } else { %>bg-gradient-to-r from-brand-500 to-brand-600 text-white hover:from-brand-600 hover:to-brand-700 shadow-sm<% } %> text-xs font-medium rounded-xl text-center transition-all btn-press">查看详情</a>
            </div>
        </div>
        <% } %>
    </div>

    <!-- 分页 -->
    <%
        int currentPage = request.getAttribute("currentPage") != null ? (int) request.getAttribute("currentPage") : 1;
        int totalPages = request.getAttribute("totalPages") != null ? (int) request.getAttribute("totalPages") : 1;
        int totalCount = request.getAttribute("totalCount") != null ? (int) request.getAttribute("totalCount") : 0;
        if (totalPages > 1) {
    %>
    <nav class="flex justify-center items-center gap-2 mt-10" aria-label="分页">
        <a class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press <%= currentPage == 1 ? "pointer-events-none opacity-35" : "" %>" href="${pageContext.request.contextPath}/browse-history?page=<%= currentPage - 1 %>" aria-label="上一页">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="15 18 9 12 15 6"/>
            </svg>
        </a>
        <%
            int startP = Math.max(1, currentPage - 2);
            int endP = Math.min(totalPages, currentPage + 2);
        %>
        <% if (startP > 1) { %>
            <a class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press" href="${pageContext.request.contextPath}/browse-history?page=1">1</a>
            <% if (startP > 2) { %><span class="text-xs text-ink-muted px-1">...</span><% } %>
        <% } %>
        <% for (int p = startP; p <= endP; p++) { %>
            <a class="w-10 h-10 flex items-center justify-center <%= p == currentPage ? "bg-gradient-to-r from-brand-500 to-brand-600 text-white rounded-xl font-semibold shadow-lg shadow-brand-500/20" : "border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press" %>" href="${pageContext.request.contextPath}/browse-history?page=<%= p %>"><%= p %></a>
        <% } %>
        <% if (endP < totalPages) { %>
            <% if (endP < totalPages - 1) { %><span class="text-xs text-ink-muted px-1">...</span><% } %>
            <a class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press" href="${pageContext.request.contextPath}/browse-history?page=<%= totalPages %>"><%= totalPages %></a>
        <% } %>
        <a class="w-10 h-10 flex items-center justify-center border border-stone-200 rounded-xl text-ink-muted hover:border-brand-300 hover:text-brand-600 transition-all btn-press <%= currentPage == totalPages ? "pointer-events-none opacity-35" : "" %>" href="${pageContext.request.contextPath}/browse-history?page=<%= currentPage + 1 %>" aria-label="下一页">
            <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="9 18 15 12 9 6"/>
            </svg>
        </a>
        <span class="text-xs text-ink-muted ml-2">共 <%= totalCount %> 条</span>
    </nav>
    <% } %>

    <% } %>
</main>

</body>
</html>
