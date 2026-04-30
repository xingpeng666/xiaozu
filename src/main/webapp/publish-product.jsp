<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>发布商品 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
    :root{
        --bg:#f4f3ef;--surface:#fff;--border:rgba(0,0,0,0.09);--text:#1a1a1a;--muted:#737373;
        --primary:#0b6e63;--primary-h:#085c52;--primary-hl:#d0eae7;
        --danger:#dc2626;
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
    .page{max-width:920px;margin:36px auto;padding:0 16px 48px}
    .card{background:var(--surface);border:1px solid var(--border);border-radius:var(--radius);box-shadow:var(--shadow);overflow:hidden}
    .card-top{padding:24px 28px 16px;border-bottom:1px solid var(--border)}
    .card-top h2{font-size:21px;font-weight:700;margin-bottom:4px}
    .card-top p{font-size:13.5px;color:var(--muted)}
    .alert-error{margin:16px 28px 0;padding:11px 14px;border-radius:8px;font-size:13.5px;background:var(--error-bg);border:1px solid var(--error-bd);color:var(--error-tx)}
    .form-area{padding:24px 28px 28px}
    .section-label{font-size:13px;font-weight:700;color:var(--primary);text-transform:uppercase;letter-spacing:.06em;margin-bottom:16px}
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
    .img-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px}
    .tips-box{
        margin-top:20px;padding:14px 16px;
        background:var(--primary-hl);border:1px solid #a7d9d4;
        border-radius:10px;color:#1a4a45;font-size:13px;line-height:1.8;
    }
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
        <a href="${pageContext.request.contextPath}/product-list">商品列表</a>
        <a href="${pageContext.request.contextPath}/index.jsp">首页</a>
    </div>
</nav>
<div class="page">
    <div class="card">
        <div class="card-top">
            <h2>发布商品</h2>
            <p>填写商品基本信息后，提交即可上架到平台展示。</p>
        </div>
        <c:if test="${not empty errorMsg}">
            <div class="alert-error">${errorMsg}</div>
        </c:if>
        <div class="form-area">
            <div class="section-label">商品信息</div>
            <form action="${pageContext.request.contextPath}/publish-product" method="post" enctype="multipart/form-data">
                <div class="form-grid">
                    <div class="form-item full">
                        <label>商品标题<span class="required">*</span></label>
                        <input type="text" name="title" maxlength="120" required value="${param.title}" placeholder="例如：高等数学教材、宿舍小电扇">
                        <div class="hint">标题尽量简洁清楚，方便别人搜索到。</div>
                    </div>
                    <div class="form-item">
                        <label>售价<span class="required">*</span></label>
                        <input type="number" name="price" step="0.01" min="0" required value="${param.price}" placeholder="请输入售价">
                    </div>
                    <div class="form-item">
                        <label>原价</label>
                        <input type="number" name="originalPrice" step="0.01" min="0" value="${param.originalPrice}" placeholder="选填">
                    </div>
                    <div class="form-item">
                        <label>商品成色<span class="required">*</span></label>
                        <select name="conditionLevel" required>
                            <option value="">—请选择—</option>
                            <option value="NEW" <c:if test="${param.conditionLevel eq 'NEW'}">selected</c:if>>全新</option>
                            <option value="NINETY_NEW" <c:if test="${param.conditionLevel eq 'NINETY_NEW'}">selected</c:if>>九成新</option>
                            <option value="EIGHTY_NEW" <c:if test="${param.conditionLevel eq 'EIGHTY_NEW'}">selected</c:if>>八成新</option>
                            <option value="SEVENTY_NEW" <c:if test="${param.conditionLevel eq 'SEVENTY_NEW'}">selected</c:if>>七成新及以下</option>
                        </select>
                    </div>
                    <div class="form-item">
                        <label>商品分类<span class="required">*</span></label>
                        <select name="categoryId" required>
                            <option value="">请选择分类</option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.categoryId}" <c:if test="${param.categoryId eq cat.categoryId.toString()}">selected</c:if>>${cat.categoryName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="form-item full">
                        <label>商品描述</label>
                        <textarea name="description" placeholder="请填写商品使用情况、是否有瑕疵、交易方式等信息">${param.description}</textarea>
                        <div class="hint">建议写清楚：新旧程度、是否可小刀、交易地点、是否支持当面验货。</div>
                    </div>
                    <div class="form-item full">
                        <label>封面图片<span class="required">*</span></label>
                        <input type="file" name="coverImage" accept="image/*" required>
                        <div class="hint">用于商品列表展示，支持 jpg/png/jpeg，单张不超过 10MB。</div>
                    </div>
                    <div class="form-item full">
                        <label>详情图片</label>
                        <input type="file" name="detailImages" accept="image/*" multiple>
                        <div class="hint">可一次选择多张，用于详情页展示；单张不超过 10MB，总不超过 50MB。</div>
                    </div>
                    <div class="form-item full">
                        <label>额外展示图片（图片URL）</label>
                        <div class="img-grid">
                            <input type="text" name="imageUrl1" placeholder="图片URL 1（选填）" value="${param.imageUrl1}">
                            <input type="text" name="imageUrl2" placeholder="图片URL 2（选填）" value="${param.imageUrl2}">
                            <input type="text" name="imageUrl3" placeholder="图片URL 3（选填）" value="${param.imageUrl3}">
                            <input type="text" name="imageUrl4" placeholder="图片URL 4（选填）" value="${param.imageUrl4}">
                        </div>
                        <div class="hint">可填入外部图片链接，最多 4 张，将在详情页以轮播图展示。</div>
                    </div>
                </div>
                <div style="margin-top:14px">
                    <label style="display:flex;align-items:center;gap:8px;cursor:pointer;font-size:13.5px">
                        <input type="checkbox" name="isGraduation" value="1" style="width:auto" <c:if test="${param.isGraduation eq '1'}">checked</c:if>>
                        这是毕业季商品（将在「毕业季专区」展示）
                    </label>
                </div>
                <div class="action-bar">
                    <button type="submit" class="btn-submit">立即发布</button>
                    <a href="${pageContext.request.contextPath}/product-list" class="btn-back">返回列表</a>
                </div>
                <div class="tips-box">
                    💡 温馨提示：发布前请确认商品描述真实、价格合理，避免填写联系方式等敏感信息。
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>
