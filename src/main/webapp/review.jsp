<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    Object orderIdObj      = request.getAttribute("orderId");
    Object productTitleObj = request.getAttribute("productTitle");
    Object roleObj         = request.getAttribute("role");
    int orderId      = orderIdObj != null ? (int) orderIdObj : 0;
    String productTitle = productTitleObj != null ? productTitleObj.toString() : "";
    String role         = roleObj != null ? roleObj.toString() : "BUYER";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>评价交易 — 民大二手交易平台</title>
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
        .nav-links .btn-logout { margin-left: 6px; padding: 6px 14px; background: var(--primary); color: #fff; border-radius: 7px; }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }

        .container { max-width: 560px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { margin-bottom: 24px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }

        .info-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 16px 18px; margin-bottom: 20px;
        }
        .info-card .label { font-size: 13px; color: var(--text-muted); margin-bottom: 4px; }
        .info-card .title { font-size: 15px; font-weight: 600; }
        .badge {
            display: inline-block; padding: 3px 10px; border-radius: 20px;
            font-size: 12px; font-weight: 600;
            background: var(--primary-hl); color: var(--primary);
        }

        .form-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow);
            padding: 24px 22px;
        }
        .form-group { margin-bottom: 22px; }
        .form-group label {
            display: block; font-size: 13px; font-weight: 600;
            margin-bottom: 10px;
        }

        /* Star rating */
        .star-group { display: flex; flex-direction: row-reverse; justify-content: flex-end; gap: 4px; }
        .star-group input[type=radio] { display: none; }
        .star-group label {
            font-size: 2rem; color: #d1d5db; cursor: pointer;
            transition: color 0.12s; margin-bottom: 0;
        }
        .star-group input[type=radio]:checked ~ label,
        .star-group label:hover,
        .star-group label:hover ~ label { color: #f59e0b; }

        textarea {
            width: 100%; padding: 11px 13px;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-size: 14px; font-family: var(--font);
            resize: vertical; min-height: 110px;
            outline: none; transition: border-color 0.18s, box-shadow 0.18s;
        }
        textarea:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(11,110,99,0.1);
        }
        textarea::placeholder { color: #b0b0b0; }

        .form-actions { display: flex; gap: 10px; }
        .btn {
            padding: 10px 22px; border-radius: 8px; font-size: 14px; font-weight: 600;
            font-family: var(--font); cursor: pointer; border: none; transition: all 0.15s;
            text-decoration: none; display: inline-block;
        }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-primary:hover { background: var(--primary-h); }
        .btn-outline {
            background: transparent; color: var(--text-muted);
            border: 1.5px solid var(--border);
        }
        .btn-outline:hover { border-color: var(--primary); color: var(--primary); }
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
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>评价交易</h1>
    </div>

    <div class="info-card">
        <div class="label">商品</div>
        <div class="title"><%=productTitle%></div>
        <div style="margin-top:8px;">你的身份：<span class="badge"><%="BUYER".equals(role)?"买家":"卖家"%></span></div>
    </div>

    <div class="form-card">
        <form method="post" action="<%=request.getContextPath()%>/review">
            <input type="hidden" name="orderId" value="<%=orderId%>">
            <div class="form-group">
                <label>评分（必填）</label>
                <div class="star-group">
                    <input type="radio" id="s5" name="score" value="5"><label for="s5">★</label>
                    <input type="radio" id="s4" name="score" value="4"><label for="s4">★</label>
                    <input type="radio" id="s3" name="score" value="3" checked><label for="s3">★</label>
                    <input type="radio" id="s2" name="score" value="2"><label for="s2">★</label>
                    <input type="radio" id="s1" name="score" value="1"><label for="s1">★</label>
                </div>
            </div>
            <div class="form-group">
                <label>评价内容（可选）</label>
                <textarea name="content" maxlength="300" placeholder="分享你的交易体验..."></textarea>
            </div>
            <div class="form-actions">
                <button type="submit" class="btn btn-primary">提交评价</button>
                <a href="<%=request.getContextPath()%>/orders?type=buy" class="btn btn-outline">返回订单</a>
            </div>
        </form>
    </div>
</div>

</body>
</html>
