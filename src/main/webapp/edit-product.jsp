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
    <title>编辑商品 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
    :root{
        --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
        --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
        --danger:#dc2626;
        --success-bg:#f0fdf4;--success-bd:#bbf7d0;--success-tx:#15803d;
        --error-bg:#fff1f0;--error-bd:#ffc5c5;--error-tx:#b91c1c;
        --radius:12px;--font:'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
        --shadow:0 4px 20px rgba(0,0,0,0.06);
    }
    *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
    html{-webkit-font-smoothing:antialiased}
    body{font-family:var(--font);background:var(--bg);color:var(--text);min-height:100dvh}
    .nav{height:56px;background:var(--surface);border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;padding:0 28px;position:sticky;top:0;z-index:100}
    .nav-brand{display:flex;align-items:center;gap:9px;font-size:16px;font-weight:700;color:var(--primary);text-decoration:none}
    .nav-links{display:flex;align-items:center;gap:4px}
    .nav-links a{font-size:13.5px;font-weight:500;color:var(--muted);text-decoration:none;padding:6px 11px;border-radius:7px;transition:background .15s,color .15s}
    .nav-links a:hover{background:var(--primary-hl);color:var(--primary)}
    .nav-links .btn-logout{margin-left:6px;padding:6px 14px;background:var(--primary);color:#fff;border-radius:7px}
    .nav-links .btn-logout:hover{background:var(--primary-h);color:#fff}
    .page{max-width:920px;margin:36px auto;padding:0 16px 48px}
    .card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden}
    .card-top{padding:24px 28px 16px;border-bottom:1px solid var(--border)}
    .card-top h2{font-size:21px;font-weight:700;margin-bottom:4px}
    .card-top p{font-size:13.5px;color:var(--muted)}
    .alert{margin:16px 28px 0;padding:11px 14px;border-radius:8px;font-size:13.5px}
    .alert-success{background:var(--success-bg);border:1px solid var(--success-bd);color:var(--success-tx)}
    .alert-error{background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
    .form-area{padding:24px 28px 28px}
    .section-label{font-size:13px;font-weight:700;color:var(--primary);text-transform:uppercase;letter-spacing:.06em;margin-bottom:16px;margin-top:4px}
    .form-grid{display:grid;grid-template-columns:1fr 1fr;gap:16px 20px}
    .form-item{display:flex;flex-direction:column}
    .form-item.full{grid-column:1/span 2}
    .form-item label{font-size:13.5px;font-weight:600;margin-bottom:6px}
    .required{color:var(--danger);margin-left:3px}
    .form-item input,.form-item select,.form-item textarea{
        width:100%;padding:10px 12px;border:1.5px solid var(--border);border-radius:8px;
        font-size:13.5px;font-family:var(--font);background:var(--surface);outline:none;
        transition:border-color .15s,box-shadow .15s;
    }
    .form-item input:focus,.form-item select:focus,.form-item textarea:focus{
        border-color:var(--primary);box-shadow:0 0 0 3px rgba(11,110,99,0.1);
    }
    .form-item textarea{min-height:120px;resize:vertical}
    .hint{margin-top:5px;font-size:12px;color:var(--muted)}
    .cover-preview{margin-top:10px;display:flex;align-items:center;gap:12px}
    .cover-preview img{width:80px;height:80px;object-fit:cover;border-radius:8px;border:1px solid var(--border)}
    .cover-preview span{font-size:12px;color:var(--muted)}
    .img-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
    .action-bar{margin-top:24px;display:flex;gap:10px;align-items:center}
    .btn-submit{background:var(--primary);color:#fff;border:none;padding:10px 22px;border-radius:8px;font-size:14px;font-weight:600;font-family:var(--font);cursor:pointer;transition:background .15s}
    .btn-submit:hover{background:var(--primary-h)}
    .btn-back{display:inline-block;text-decoration:none;color:var(--muted);background:var(--surface);border:1.5px solid var(--border);padding:9px 18px;border-radius:8px;font-size:14px;font-weight:500;transition:all .15s}
    .btn-back:hover{border-color:var(--primary);color:var(--primary)}
    @media(max-width:768px){
        .form-grid{grid-template-columns:1fr}.form-item.full{grid-column:auto}
        .action-bar{flex-direction:column;align-items:stretch}
        .btn-submit,.btn-back{text-align:center}
    }
    </style>
</head>
<body>
<nav class="nav">
    <a class="nav-brand" href="${pageContext.request.contextPath}/index.jsp">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/><line x1="3" y1="6" x2="21" y2="6"/><path d="M16 10a4 4 0 0 1-8 0"/></svg>
        民大二手交易平台
    </a>
    <div class="nav-links">
        <a href="${pageContext.request.contextPath}/my-products">我的商品</a>
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
    </div>
</nav>
<div class="page">
    <div class="card">
        <div class="card-top">
            <h2>编辑商品</h2>
            <p>修改商品信息后点击保存，封面图不选则保留原图。</p>
        </div>
        <% if (successMsg != null) { %><div class="alert alert-success"><%= successMsg %></div><% } %>
        <% if (sessionErrorMsg != null) { %><div class="alert alert-error"><%= sessionErrorMsg %></div>
        <% } else if (request.getAttribute("errorMsg") != null) { %><div class="alert alert-error"><%= request.getAttribute("errorMsg") %></div><% } %>
        <div class="form-area">
            <div class="section-label">商品信息</div>
            <form action="${pageContext.request.contextPath}/edit-product" method="post" enctype="multipart/form-data">
                <input type="hidden" name="productId" value="<%= product.getProductId() %>">
                <div class="form-grid">
                    <div class="form-item full">
                        <label>商品标题<span class="required">*</span></label>
                        <input type="text" name="title" maxlength="120" required value="<%= product.getTitle() %>" placeholder="例如：高等数学教材、宿舍小电扇">
                    </div>
                    <div class="form-item">
                        <label>售价<span class="required">*</span></label>
                        <input type="number" name="price" step="0.01" min="0" required value="<%= product.getPrice() %>" placeholder="请输入售价">
                    </div>
                    <div class="form-item">
                        <label>原价</label>
                        <input type="number" name="originalPrice" step="0.01" min="0" value="<%= product.getOriginalPrice() != null ? product.getOriginalPrice() : "" %>" placeholder="选填">
                    </div>
                    <div class="form-item">
                        <label>商品成色<span class="required">*</span></label>
                        <select name="conditionLevel" required>
                            <option value="">—请选择—</option>
                            <option value="NEW" <%= "NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>全新</option>
                            <option value="NINETY_NEW" <%= "NINETY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>九成新</option>
                            <option value="EIGHTY_NEW" <%= "EIGHTY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>八成新</option>
                            <option value="SEVENTY_NEW" <%= "SEVENTY_NEW".equals(product.getConditionLevel()) ? "selected" : "" %>>七成新及以下</option>
                        </select>
                    </div>
                    <div class="form-item">
                        <label>商品分类<span class="required">*</span></label>
                        <select name="categoryId" required>
                            <option value="">请选择分类</option>
                            <% if (categories != null) { for (Map<String,Object> cat : categories) { %>
                            <option value="<%= cat.get("categoryId") %>" <%= cat.get("categoryId").equals(product.getCategoryId()) ? "selected" : "" %>>
                                <%= cat.get("categoryName") %>
                            </option>
                            <% } } %>
                        </select>
                    </div>
                    <div class="form-item full">
                        <label>商品描述</label>
                        <textarea name="description" placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息"><%= product.getDescription() != null ? product.getDescription() : "" %></textarea>
                    </div>
                    <div class="form-item full">
                        <label>封面图片（不选则保留原图）</label>
                        <input type="file" name="coverImage" accept="image/*">
                        <div class="hint">支持 jpg/png/jpeg，单张不超过 10MB。</div>
                        <% if (product.getCoverImageUrl() != null && !product.getCoverImageUrl().isEmpty()) { %>
                        <div class="cover-preview">
                            <img src="<%= product.getCoverImageUrl() %>" alt="封面预览">
                            <span>当前封面图，重新选择则替换</span>
                        </div>
                        <% } %>
                    </div>
                    <div class="form-item full">
                        <label>额外展示图片（图片URL）</label>
                        <%
                            String existingUrls = product.getImageUrls();
                            String[] urlArr = (existingUrls != null && !existingUrls.isEmpty()) ? existingUrls.split(",", -1) : new String[]{"","","",""};
                        %>
                        <div class="img-grid">
                            <input type="text" name="imageUrl1" placeholder="图片URL 1（选填）" value="<%= urlArr.length > 0 ? urlArr[0] : "" %>">
                            <input type="text" name="imageUrl2" placeholder="图片URL 2（选填）" value="<%= urlArr.length > 1 ? urlArr[1] : "" %>">
                            <input type="text" name="imageUrl3" placeholder="图片URL 3（选填）" value="<%= urlArr.length > 2 ? urlArr[2] : "" %>">
                            <input type="text" name="imageUrl4" placeholder="图片URL 4（选填）" value="<%= urlArr.length > 3 ? urlArr[3] : "" %>">
                        </div>
                        <div class="hint">可填入外部图片链接，与封面图搞配轮播展示。</div>
                    </div>
                </div>
                <div style="margin-top:14px">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13.5px">
                        <input type="checkbox" name="isGraduation" value="1" style="width:auto"
                            <%= product.getTags() != null && product.getTags().contains("graduation") ? "checked" : "" %>>
                        这是毕业季商品（将在「毕业季专区」展示）
                    </label>
                </div>
                <div class="action-bar">
                    <button type="submit" class="btn-submit">保存修改</button>
                    <a href="${pageContext.request.contextPath}/my-products" class="btn-back">返回我的商品</a>
                    <a href="${pageContext.request.contextPath}/product-detail?id=<%= product.getProductId() %>" class="btn-back">查看商品详情</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
