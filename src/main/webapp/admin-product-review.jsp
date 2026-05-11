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
    boolean isPending = "pending".equals(tab);
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>商品审核 - 民大二手交易平台</title>
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
    .btn-press { transition: transform 0.15s ease, box-shadow 0.15s ease; }
    .btn-press:active { transform: scale(0.97); }
</style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="admin-products"/>
    <jsp:param name="isAdmin" value="true"/>
</jsp:include>

<main class="max-w-6xl mx-auto px-4 py-8">
    <h1 class="font-display text-xl font-bold text-ink-primary mb-6 flex items-center gap-2">
        <svg class="w-5 h-5 text-brand-500" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
        商品审核
    </h1>

    <% if (errMsg != null) { %>
    <div class="bg-red-50 border border-red-200 text-red-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
        <%=errMsg%>
    </div>
    <% } %>
    <% if (sucMsg != null) { %>
    <div class="bg-green-50 border border-green-200 text-green-700 rounded-lg px-4 py-3 text-sm mb-4 flex items-center gap-2">
        <svg class="w-4 h-4 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
        <%=sucMsg%>
    </div>
    <% } %>

    <div class="flex gap-0 border-b-2 border-stone-200 mb-6">
        <a href="?tab=pending" class="px-5 py-2.5 text-sm font-semibold border-b-2 -mb-0.5 transition-colors <%="pending".equals(tab)?"text-brand-600 border-brand-500":"text-ink-muted border-transparent hover:text-brand-600"%>">待审核</a>
        <a href="?tab=on_sale" class="px-5 py-2.5 text-sm font-semibold border-b-2 -mb-0.5 transition-colors <%="on_sale".equals(tab)?"text-brand-600 border-brand-500":"text-ink-muted border-transparent hover:text-brand-600"%>">已通过</a>
        <a href="?tab=rejected" class="px-5 py-2.5 text-sm font-semibold border-b-2 -mb-0.5 transition-colors <%="rejected".equals(tab)?"text-brand-600 border-brand-500":"text-ink-muted border-transparent hover:text-brand-600"%>">已驳回</a>
    </div>

    <% if (productList.isEmpty()) { %>
    <div class="text-center py-16 bg-surface-raised border border-stone-200 rounded-xl">
        <svg class="w-12 h-12 text-stone-300 mx-auto mb-3" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5"><path d="m7.5 4.27 9 5.15"/><path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z"/><path d="m3.3 7 8.7 5 8.7-5"/><path d="M12 22V12"/></svg>
        <p class="text-sm text-ink-muted">暂无商品</p>
    </div>
    <% } else { %>
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-sm overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full divide-y divide-stone-200">
                <thead>
                    <tr class="bg-stone-50">
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">ID</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">封面</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">标题</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">分类</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">价格</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">新旧</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">发布人</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">学号</th>
                        <th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">时间</th>
                        <% if (isPending) { %><th class="text-left text-xs font-semibold text-ink-muted uppercase tracking-wider px-4 py-3">操作</th><% } %>
                    </tr>
                </thead>
                <tbody class="divide-y divide-stone-100">
                <% for (Map<String,Object> p : productList) { %>
                <tr class="hover:bg-stone-50 transition-colors">
                    <td class="px-4 py-3 text-sm text-ink-primary"><%=p.get("productId")%></td>
                    <td class="px-4 py-3">
                        <% String img = (String) p.get("coverImageUrl"); if (img != null && !img.isEmpty()) { %>
                        <img src="<%=img%>" class="w-12 h-12 object-cover rounded-lg border border-stone-200" alt="">
                        <% } else { %><span class="text-xs text-ink-faint">无图</span><% } %>
                    </td>
                    <td class="px-4 py-3 text-sm text-ink-primary font-medium"><%=p.get("title")%></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%=p.get("categoryName") != null ? p.get("categoryName") : "—"%></td>
                    <td class="px-4 py-3 text-sm text-ink-primary font-semibold">&yen;<%=p.get("price")%></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%
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
                    <td class="px-4 py-3 text-sm text-ink-muted"><%=p.get("sellerName")%></td>
                    <td class="px-4 py-3 text-sm text-ink-muted"><%=p.get("sellerNo")%></td>
                    <td class="px-4 py-3 text-xs text-ink-muted whitespace-nowrap"><%=p.get("createdAt") != null ? p.get("createdAt").toString().substring(0,10) : "-"%></td>
                    <% if (isPending) { %>
                    <td class="px-4 py-3 whitespace-nowrap">
                        <form method="post" action="${pageContext.request.contextPath}/admin/products" style="display:inline">
                            <input type="hidden" name="productId" value="<%=p.get("productId")%>">
                            <input type="hidden" name="tab" value="pending">
                            <input type="hidden" name="action" value="approve">
                            <button class="bg-brand-500 text-white px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-brand-600 transition-colors btn-press">通过</button>
                        </form>
                        <form method="post" action="${pageContext.request.contextPath}/admin/products" style="display:inline;margin-left:6px">
                            <input type="hidden" name="productId" value="<%=p.get("productId")%>">
                            <input type="hidden" name="tab" value="pending">
                            <input type="hidden" name="action" value="reject">
                            <button class="bg-red-50 text-red-600 border border-red-200 px-3 py-1.5 rounded-lg text-xs font-semibold hover:bg-red-100 transition-colors btn-press">驳回</button>
                        </form>
                    </td>
                    <% } %>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <% } %>
</main>
</body>
</html>
