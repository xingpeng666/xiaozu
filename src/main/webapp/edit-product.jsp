<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="com.minzu.entity.User" %>
<%@ page import="com.minzu.entity.Product" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%
    User loginUser = (User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    Product product = (Product) request.getAttribute("product");
    List<Map<String, Object>> categories = (List<Map<String, Object>>) request.getAttribute("categories");
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>编辑商品 - 民大二手交易平台</title>
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
        .input-focus-ring:focus { outline: none; box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.15); }
    </style>
</head>
<body class="font-body min-h-screen bg-surface-DEFAULT">

<jsp:include page="/common/header.jsp">
    <jsp:param name="active" value="my-products"/>
</jsp:include>

<main class="max-w-3xl mx-auto px-4 py-8">
    <div class="bg-surface-raised border border-stone-200 rounded-xl shadow-lg overflow-hidden">
        <div class="px-8 py-6 border-b border-stone-100 bg-gradient-to-br from-brand-50 to-transparent">
            <h1 class="font-display text-xl font-bold text-ink-primary mb-1">编辑商品</h1>
            <p class="text-sm text-ink-muted">修改商品信息后点击保存，封面图不选则保留原图。</p>
        </div>

        <% if (successMsg != null) { %>
        <div class="px-8 pt-4">
            <div class="bg-green-50 border border-green-200 rounded-lg px-4 py-3 flex items-center gap-3">
                <svg class="w-5 h-5 text-green-600 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
                <span class="text-green-700 text-sm"><%= successMsg %></span>
            </div>
        </div>
        <% } %>
        <% if (sessionErrorMsg != null) { %>
        <div class="px-8 pt-4">
            <div class="bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span class="text-red-700 text-sm"><%= sessionErrorMsg %></span>
            </div>
        </div>
        <% } else if (request.getAttribute("errorMsg") != null) { %>
        <div class="px-8 pt-4">
            <div class="bg-red-50 border border-red-200 rounded-lg px-4 py-3 flex items-center gap-3">
                <svg class="w-5 h-5 text-red-600 flex-shrink-0" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                <span class="text-red-700 text-sm"><%= request.getAttribute("errorMsg") %></span>
            </div>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/edit-product" method="post" enctype="multipart/form-data" class="px-8 py-6 space-y-6">
            <input type="hidden" name="productId" value="<%= product.getProductId() %>">

            <div class="flex items-center gap-2 text-brand-600 font-display font-semibold text-sm uppercase tracking-wide">
                <svg class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="9" y1="3" x2="9" y2="21"/></svg>
                商品信息
            </div>

            <div>
                <label for="title" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">商品标题 <span class="text-red-500">*</span></label>
                <input type="text" id="title" name="title" maxlength="120" required value="<%= product.getTitle() %>" placeholder="例如：高等数学教材、宿舍小电扇"
                    class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label for="price" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">售价 <span class="text-red-500">*</span></label>
                    <input type="number" id="price" name="price" step="0.01" min="0" required value="<%= product.getPrice() %>" placeholder="请输入售价"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
                <div>
                    <label for="originalPrice" class="text-sm font-medium text-ink-primary mb-2 block">原价</label>
                    <input type="number" id="originalPrice" name="originalPrice" step="0.01" min="0" value="<%= product.getOriginalPrice() != null ? product.getOriginalPrice() : "" %>" placeholder="选填"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors">
                </div>
            </div>

            <div class="grid grid-cols-2 gap-4">
                <div>
                    <label for="conditionLevel" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">商品成色 <span class="text-red-500">*</span></label>
                    <select id="conditionLevel" name="conditionLevel" required
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
                        <option value="">请选择</option>
                        <option value="NEW" <%= "NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>全新</option>
                        <option value="NINETY_NEW" <%= "NINETY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>九成新</option>
                        <option value="EIGHTY_NEW" <%= "EIGHTY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>八成新</option>
                        <option value="SEVENTY_NEW" <%= "SEVENTY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>七成新及以下</option>
                    </select>
                </div>
                <div>
                    <label for="categoryId" class="flex items-center gap-1 text-sm font-medium text-ink-primary mb-2">商品分类 <span class="text-red-500">*</span></label>
                    <select id="categoryId" name="categoryId" required
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary input-focus-ring focus:border-brand-500 transition-colors">
                        <option value="">请选择分类</option>
                        <% if (categories != null) { for (Map<String,Object> cat : categories) { %>
                        <option value="<%= cat.get("categoryId") %>" <%= cat.get("categoryId").equals(product.getCategoryId()) ? "selected" : "" %>><%= cat.get("categoryName") %></option>
                        <% } } %>
                    </select>
                </div>
            </div>

            <div>
                <label for="description" class="text-sm font-medium text-ink-primary mb-2 block">商品描述</label>
                <textarea id="description" name="description" placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息"
                    class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors resize-y min-h-[120px]"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
            </div>

            <div>
                <label class="text-sm font-medium text-ink-primary mb-2 block">封面图片（不选则保留原图）</label>
                <input type="file" name="coverImage" accept="image/*"
                    class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary text-sm input-focus-ring focus:border-brand-500 transition-colors">
                <p class="mt-2 text-xs text-ink-faint">支持 jpg/png/jpeg，单张不超过 10MB。</p>
                <% if (product.getCoverImageUrl() != null && !product.getCoverImageUrl().isEmpty()) { %>
                <div class="flex items-center gap-3 mt-3">
                    <img src="<%= product.getCoverImageUrl() %>" alt="封面预览" class="w-20 h-20 object-cover rounded-lg border border-stone-200">
                    <span class="text-xs text-ink-muted">当前封面图，重新选择则替换</span>
                </div>
                <% } %>
            </div>

            <div>
                <label class="text-sm font-medium text-ink-primary mb-2 block">额外展示图片（图片URL）</label>
                <%
                    String existingUrls = product.getImageUrls();
                    String[] urlArr = (existingUrls != null && !existingUrls.isEmpty()) ? existingUrls.split(",", -1) : new String[]{"","","",""};
                %>
                <div class="grid grid-cols-2 gap-3">
                    <input type="text" name="imageUrl1" placeholder="图片URL 1（选填）" value="<%= urlArr.length > 0 ? urlArr[0] : "" %>"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors text-sm">
                    <input type="text" name="imageUrl2" placeholder="图片URL 2（选填）" value="<%= urlArr.length > 1 ? urlArr[1] : "" %>"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors text-sm">
                    <input type="text" name="imageUrl3" placeholder="图片URL 3（选填）" value="<%= urlArr.length > 2 ? urlArr[2] : "" %>"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors text-sm">
                    <input type="text" name="imageUrl4" placeholder="图片URL 4（选填）" value="<%= urlArr.length > 3 ? urlArr[3] : "" %>"
                        class="w-full px-4 py-3 bg-surface-raised border border-stone-200 rounded-lg text-ink-primary placeholder:text-ink-faint input-focus-ring focus:border-brand-500 transition-colors text-sm">
                </div>
                <p class="mt-2 text-xs text-ink-faint">可填入外部图片链接，与封面图搭配轮播展示。</p>
            </div>

            <label class="flex items-center gap-2 cursor-pointer text-sm text-ink-primary">
                <input type="checkbox" name="isGraduation" value="1" class="w-4 h-4 rounded border-stone-300 text-brand-500 focus:ring-brand-500"
                    <%= product.getTags() != null && product.getTags().contains("graduation") ? "checked" : "" %>>
                这是毕业季商品（将在「毕业季专区」展示）
            </label>

            <div class="flex gap-3 pt-2">
                <button type="submit" class="bg-brand-500 text-white px-5 py-2.5 rounded-lg hover:bg-brand-600 transition-colors btn-press font-medium text-sm">保存修改</button>
                <a href="${pageContext.request.contextPath}/my-products" class="border border-stone-200 text-ink-muted px-5 py-2.5 rounded-lg hover:border-brand-500 hover:text-brand-600 transition-colors font-medium text-sm">返回我的商品</a>
                <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.getProductId() %>" class="border border-stone-200 text-ink-muted px-5 py-2.5 rounded-lg hover:border-brand-500 hover:text-brand-600 transition-colors font-medium text-sm">查看商品详情</a>
            </div>
        </form>
    </div>
</main>

</body>
</html>
