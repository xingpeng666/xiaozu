<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>登录 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:          #f4f3ef;
            --surface:     #ffffff;
            --border:      rgba(0,0,0,0.09);
            --text:        #1a1a1a;
            --text-muted:  #737373;
            --primary:     #0b6e63;
            --primary-h:   #085c52;
            --primary-hl:  #d0eae7;
            --error-bg:    #fff1f0;
            --error-bd:    #ffc5c5;
            --error-tx:    #b91c1c;
            --success-bg:  #f0fdf4;
            --success-bd:  #bbf7d0;
            --success-tx:  #15803d;
            --radius:      12px;
            --font:        'Plus Jakarta Sans', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            --shadow:      0 8px 32px rgba(0,0,0,0.08);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body {
            font-family: var(--font);
            background: var(--bg);
            color: var(--text);
            min-height: 100dvh;
            display: grid;
            grid-template-columns: 1fr 1fr;
        }

        /* LEFT PANEL */
        .left-panel {
            background: var(--primary);
            display: flex;
            flex-direction: column;
            justify-content: center;
            padding: 60px 56px;
            position: relative;
            overflow: hidden;
        }
        .left-panel::before {
            content: '';
            position: absolute;
            width: 400px; height: 400px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            top: -80px; right: -120px;
        }
        .left-panel::after {
            content: '';
            position: absolute;
            width: 280px; height: 280px;
            background: rgba(255,255,255,0.04);
            border-radius: 50%;
            bottom: -60px; left: -80px;
        }
        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 48px;
        }
        .brand-logo {
            width: 40px; height: 40px;
            background: rgba(255,255,255,0.15);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }
        .brand-logo svg { color: #fff; }
        .brand-name { font-size: 17px; font-weight: 700; color: #fff; letter-spacing: 0.02em; }
        .panel-title {
            font-size: clamp(26px, 3vw, 34px);
            font-weight: 700;
            color: #fff;
            line-height: 1.3;
            margin-bottom: 16px;
        }
        .panel-desc {
            font-size: 15px;
            color: rgba(255,255,255,0.7);
            line-height: 1.7;
            max-width: 340px;
        }
        .feature-list {
            margin-top: 40px;
            display: flex;
            flex-direction: column;
            gap: 14px;
            list-style: none;
        }
        .feature-list li {
            display: flex;
            align-items: center;
            gap: 10px;
            color: rgba(255,255,255,0.85);
            font-size: 14px;
        }
        .feature-dot {
            width: 7px; height: 7px;
            border-radius: 50%;
            background: rgba(255,255,255,0.5);
            flex-shrink: 0;
        }

        /* RIGHT PANEL */
        .right-panel {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 24px;
        }
        .form-box {
            width: 100%;
            max-width: 400px;
        }
        .form-title {
            font-size: 24px;
            font-weight: 700;
            color: var(--text);
            margin-bottom: 6px;
        }
        .form-subtitle {
            font-size: 14px;
            color: var(--text-muted);
            margin-bottom: 36px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            font-size: 13px;
            font-weight: 600;
            color: var(--text);
            margin-bottom: 7px;
            letter-spacing: 0.01em;
        }
        .form-group input {
            width: 100%;
            padding: 11px 14px;
            border: 1.5px solid var(--border);
            border-radius: 9px;
            font-size: 14px;
            font-family: var(--font);
            background: #fafafa;
            color: var(--text);
            outline: none;
            transition: border-color 0.18s, box-shadow 0.18s, background 0.18s;
        }
        .form-group input:focus {
            border-color: var(--primary);
            background: #fff;
            box-shadow: 0 0 0 3px rgba(11,110,99,0.1);
        }
        .form-group input::placeholder { color: #b0b0b0; }
        .btn-submit {
            width: 100%;
            padding: 12px;
            background: var(--primary);
            color: #fff;
            border: none;
            border-radius: 9px;
            font-size: 15px;
            font-weight: 600;
            font-family: var(--font);
            cursor: pointer;
            transition: background 0.18s, transform 0.1s;
            margin-top: 4px;
        }
        .btn-submit:hover { background: var(--primary-h); }
        .btn-submit:active { transform: scale(0.99); }
        .bottom-row {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: var(--text-muted);
        }
        .bottom-row a {
            color: var(--primary);
            font-weight: 600;
            text-decoration: none;
        }
        .bottom-row a:hover { text-decoration: underline; }
        .alert {
            padding: 11px 14px;
            border-radius: 8px;
            font-size: 13.5px;
            margin-bottom: 20px;
            display: flex;
            align-items: flex-start;
            gap: 8px;
            line-height: 1.5;
        }
        .alert-error {
            background: var(--error-bg);
            border: 1px solid var(--error-bd);
            color: var(--error-tx);
        }
        .alert-success {
            background: var(--success-bg);
            border: 1px solid var(--success-bd);
            color: var(--success-tx);
        }
        .divider {
            display: flex; align-items: center; gap: 12px;
            margin: 24px 0 22px;
            color: var(--text-muted);
            font-size: 12px;
        }
        .divider::before, .divider::after {
            content: ''; flex: 1;
            height: 1px; background: var(--border);
        }

        @media (max-width: 768px) {
            body { grid-template-columns: 1fr; }
            .left-panel { display: none; }
            .right-panel { padding: 48px 24px; align-items: flex-start; }
        }
    </style>
</head>
<body>

<%
    String successMsg = (String) session.getAttribute("successMsg");
    if (successMsg != null) session.removeAttribute("successMsg");
    String sessionErrorMsg = (String) session.getAttribute("errorMsg");
    if (sessionErrorMsg != null) session.removeAttribute("errorMsg");
%>

<!-- Left Panel -->
<div class="left-panel">
    <div class="brand">
        <div class="brand-logo">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
        </div>
        <span class="brand-name">民大二手交易平台</span>
    </div>
    <h1 class="panel-title">校园闲置，<br>在这里流通。</h1>
    <p class="panel-desc">连接校园买卖双方，让闲置物品找到新主人，让你的需求低价满足。</p>
    <ul class="feature-list">
        <li><span class="feature-dot"></span>教材、数码、生活用品一站发布</li>
        <li><span class="feature-dot"></span>校内自提，安全放心</li>
        <li><span class="feature-dot"></span>实名认证，买卖更有保障</li>
        <li><span class="feature-dot"></span>毕业季专区，急速清仓</li>
    </ul>
</div>

<!-- Right Panel -->
<div class="right-panel">
    <div class="form-box">
        <h2 class="form-title">欢迎回来</h2>
        <p class="form-subtitle">登录后即可浏览、发布和管理你的商品</p>

        <% if (successMsg != null) { %>
        <div class="alert alert-success"><span>✓</span><span><%= successMsg %></span></div>
        <% } %>

        <% if (sessionErrorMsg != null) { %>
        <div class="alert alert-error"><span>✕</span><span><%= sessionErrorMsg %></span></div>
        <% } else if (request.getAttribute("errorMsg") != null) { %>
        <div class="alert alert-error"><span>✕</span><span><%= request.getAttribute("errorMsg") %></span></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="form-group">
                <label for="account">学号 / 工号</label>
                <input type="text" id="account" name="account"
                       placeholder="请输入学号或工号"
                       value="<%= request.getParameter("account") == null ? "" : request.getParameter("account") %>"
                       autocomplete="username" required>
            </div>
            <div class="form-group">
                <label for="password">密码</label>
                <input type="password" id="password" name="password"
                       placeholder="请输入密码"
                       autocomplete="current-password" required>
            </div>
            <button type="submit" class="btn-submit">登 录</button>
        </form>

        <div class="divider">还没有账号？</div>

        <div class="bottom-row">
            <a href="${pageContext.request.contextPath}/register">立即免费注册</a>
        </div>
    </div>
</div>

</body>
</html>
