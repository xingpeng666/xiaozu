<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, java.math.BigDecimal" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    if (!"ADMIN".equals(loginUser.getRoleCode())) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
    long totalUsers      = request.getAttribute("totalUsers")      != null ? ((Number) request.getAttribute("totalUsers")).longValue()      : 0;
    long todayNewUsers   = request.getAttribute("todayNewUsers")   != null ? ((Number) request.getAttribute("todayNewUsers")).longValue()   : 0;
    long onSaleProducts  = request.getAttribute("onSaleProducts")  != null ? ((Number) request.getAttribute("onSaleProducts")).longValue()  : 0;
    long pendingProducts = request.getAttribute("pendingProducts") != null ? ((Number) request.getAttribute("pendingProducts")).longValue() : 0;
    long totalOrders     = request.getAttribute("totalOrders")     != null ? ((Number) request.getAttribute("totalOrders")).longValue()     : 0;
    long completedOrders = request.getAttribute("completedOrders") != null ? ((Number) request.getAttribute("completedOrders")).longValue() : 0;
    BigDecimal totalAmount = request.getAttribute("totalAmount") != null ? (BigDecimal) request.getAttribute("totalAmount") : BigDecimal.ZERO;
    List<Map<String, Object>> dailyOrders = (List<Map<String, Object>>) request.getAttribute("dailyOrders");
    if (dailyOrders == null) dailyOrders = new ArrayList<>();
    String errorMsg = (String) request.getAttribute("errorMsg");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) { request.setAttribute("successMsg", successMsg); session.removeAttribute("successMsg"); }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>管理统计面板 - 民大二手交易平台</title>
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
        .hover-lift { transition: transform 0.2s ease, box-shadow 0.2s ease; }
        .hover-lift:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(0,0,0,0.12); }
        .btn-press { transition: transform 0.1s ease; }
        .btn-press:active { transform: scale(0.97); }
        @media (prefers-reduced-motion: reduce) {
            .hover-lift, .btn-press { transition: none; }
            .hover-lift:hover { transform: none; }
            .btn-press:active { transform: none; }
        }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="dashboard"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<!-- 主内容 -->
<main class="max-w-6xl mx-auto px-4 py-8">
    <h1 class="font-display text-2xl font-bold text-ink-primary mb-6">数据统计面板</h1>

    <% if (successMsg != null) { %>
    <div class="flex items-center gap-2 px-4 py-3 bg-brand-50 border border-brand-200 rounded-xl text-brand-700 text-sm mb-6">
        <svg class="w-5 h-5 text-brand-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <span><%= successMsg %></span>
    </div>
    <% } %>
    <% if (errorMsg != null) { %>
    <div class="flex items-center gap-2 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm mb-6">
        <svg class="w-5 h-5 text-red-500 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <span><%= errorMsg %></span>
    </div>
    <% } %>

    <!-- 统计卡片 -->
    <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <!-- 用户数 -->
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 bg-brand-100 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-brand-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                </div>
                <span class="text-sm text-ink-muted">平台总用户数</span>
            </div>
            <div class="font-display text-3xl font-bold text-brand-600"><%= totalUsers %></div>
            <div class="text-xs text-ink-muted mt-1">今日新增 <span class="text-brand-500 font-medium"><%= todayNewUsers %></span> 人</div>
        </div>

        <!-- 在售商品 -->
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 bg-emerald-100 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-emerald-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                        <line x1="3" y1="6" x2="21" y2="6"/>
                        <path d="M16 10a4 4 0 0 1-8 0"/>
                    </svg>
                </div>
                <span class="text-sm text-ink-muted">在售商品数</span>
            </div>
            <div class="font-display text-3xl font-bold text-emerald-600"><%= onSaleProducts %></div>
        </div>

        <!-- 待审核 -->
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-orange-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <polyline points="12 6 12 12 16 14"/>
                    </svg>
                </div>
                <span class="text-sm text-ink-muted">待审核商品</span>
            </div>
            <div class="font-display text-3xl font-bold text-orange-600"><%= pendingProducts %></div>
        </div>

        <!-- 交易金额 -->
        <div class="bg-surface-raised border border-stone-200 rounded-2xl p-5 hover-lift">
            <div class="flex items-center gap-3 mb-3">
                <div class="w-10 h-10 bg-purple-100 rounded-lg flex items-center justify-center">
                    <svg class="w-5 h-5 text-purple-600" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <line x1="12" y1="1" x2="12" y2="23"/>
                        <path d="M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"/>
                    </svg>
                </div>
                <span class="text-sm text-ink-muted">总交易金额</span>
            </div>
            <div class="font-display text-3xl font-bold text-purple-600">&yen;<%= String.format("%.2f", totalAmount) %></div>
            <div class="text-xs text-ink-muted mt-1"><%= totalOrders %> 笔订单，已完成 <%= completedOrders %> 笔</div>
        </div>
    </div>

    <!-- 订单趋势表格 -->
    <div class="bg-surface-raised border border-stone-200 rounded-2xl p-6 mb-6 hover-lift">
        <h3 class="font-display font-semibold text-ink-primary mb-4 flex items-center gap-2">
            <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"/>
            </svg>
            近 7 天订单趋势
        </h3>
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="border-b border-stone-200">
                        <th class="text-left py-3 px-4 text-sm font-medium text-ink-muted bg-stone-50 rounded-tl-lg">日期</th>
                        <th class="text-left py-3 px-4 text-sm font-medium text-ink-muted bg-stone-50 rounded-tr-lg">订单数</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (dailyOrders.isEmpty()) { %>
                    <tr>
                        <td colspan="2" class="py-8 text-center text-sm text-ink-muted">暂无数据</td>
                    </tr>
                    <% } else {
                        for (Map<String, Object> row : dailyOrders) { %>
                    <tr class="border-b border-stone-100 hover:bg-stone-50 transition-colors">
                        <td class="py-3 px-4 text-sm text-ink-primary"><%= row.get("orderDate") %></td>
                        <td class="py-3 px-4 text-sm font-semibold text-ink-primary"><%= row.get("orderCount") %> 笔</td>
                    </tr>
                    <% } } %>
                </tbody>
            </table>
        </div>
    </div>

    <!-- 快捷入口 -->
    <div class="flex flex-wrap gap-3">
        <a href="${pageContext.request.contextPath}/admin/user-review" class="inline-flex items-center gap-2 px-5 py-3 bg-brand-500 text-white font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                <circle cx="9" cy="7" r="4"/>
            </svg>
            用户审核管理
        </a>
        <a href="${pageContext.request.contextPath}/admin/products" class="inline-flex items-center gap-2 px-5 py-3 bg-brand-500 text-white font-medium rounded-lg hover:bg-brand-600 transition-colors btn-press">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="11" cy="11" r="8"/>
                <line x1="21" y1="21" x2="16.65" y2="16.65"/>
            </svg>
            商品审核管理
        </a>
        <a href="${pageContext.request.contextPath}/report" class="inline-flex items-center gap-2 px-5 py-3 bg-brand-50 text-brand-600 font-medium rounded-lg hover:bg-brand-100 transition-colors">
            <svg class="w-5 h-5" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
            </svg>
            举报管理
        </a>
    </div>
</main>

</body>
</html>
