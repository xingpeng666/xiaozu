<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册 - 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:         #f4f3ef;
            --surface:    #ffffff;
            --surface2:   #f9f8f6;
            --border:     rgba(0,0,0,0.08);
            --text:       #1a1a1a;
            --text-muted: #737373;
            --text-faint: #b0b0b0;
            --primary:    #0b6e63;
            --primary-h:  #085c52;
            --primary-hl: #d0eae7;
            --error:      #dc2626;
            --error-bg:   #fff1f1;
            --error-bd:   #fecaca;
            --radius-sm:  8px;
            --radius:     14px;
            --shadow-sm:  0 2px 8px rgba(0,0,0,0.06);
            --shadow:     0 8px 28px rgba(0,0,0,0.08);
            --font:       'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --nav-h:      60px;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body {
            font-family: var(--font);
            font-size: 15px;
            color: var(--text);
            background: var(--bg);
            min-height: 100dvh;
            line-height: 1.6;
        }
        a { color: inherit; text-decoration: none; }
        button { cursor: pointer; font-family: var(--font); }
        button, input { font: inherit; color: inherit; }

        /* NAV */
        .nav {
            height: var(--nav-h);
            background: var(--surface);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 28px;
            position: sticky;
            top: 0;
            z-index: 100;
        }
        .nav-brand { display: flex; align-items: center; gap: 9px; }
        .nav-logo {
            width: 34px; height: 34px;
            background: var(--primary);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            color: #fff; flex-shrink: 0;
        }
        .nav-brand-name { font-size: 15px; font-weight: 700; color: var(--text); letter-spacing: 0.01em; }
        .nav-links { display: flex; align-items: center; gap: 2px; list-style: none; }
        .nav-links a {
            font-size: 14px; font-weight: 500; color: var(--text-muted);
            padding: 7px 12px; border-radius: 7px;
            transition: color 0.15s, background 0.15s;
            display: flex; align-items: center; gap: 5px;
        }
        .nav-links a:hover { color: var(--text); background: var(--bg); }
        .nav-links a.active { color: var(--primary); background: var(--primary-hl); }
        .nav-right { display: flex; align-items: center; gap: 10px; }

        /* Page layout */
        .page-wrapper {
            min-height: calc(100dvh - var(--nav-h));
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
        }
        .register-card {
            width: 100%;
            max-width: 460px;
            background: var(--surface);
            border-radius: var(--radius);
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        /* Card header */
        .card-top {
            padding: 32px 32px 20px;
            border-bottom: 1px solid var(--border);
        }
        .card-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 20px;
        }
        .card-logo-icon {
            width: 40px;
            height: 40px;
            background: var(--primary-hl);
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--primary);
        }
        .card-logo-text { font-size: 14px; font-weight: 600; color: var(--text-muted); }
        .card-top h1 { font-size: 22px; font-weight: 700; letter-spacing: -0.5px; margin-bottom: 4px; color: var(--text); }
        .card-top p { font-size: 14px; color: var(--text-muted); }

        /* Form */
        .card-body { padding: 28px 32px 32px; }
        .form-item { margin-bottom: 18px; }
        .form-item label {
            display: flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 7px;
            font-size: 14px;
            font-weight: 500;
            color: var(--text);
        }
        .required { color: #e53e3e; font-size: 13px; line-height: 1; }
        .input-wrap { position: relative; }
        .input-icon {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-faint);
            pointer-events: none;
            display: flex;
        }
        .form-input {
            width: 100%;
            padding: 10px 12px 10px 36px;
            border: 1px solid var(--border);
            border-radius: var(--radius-sm);
            font-size: 14px;
            background: var(--surface);
            color: var(--text);
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
        }
        .form-input.no-icon { padding-left: 12px; }
        .form-input::placeholder { color: var(--text-faint); }
        .form-input:hover { border-color: rgba(0,0,0,0.15); }
        .form-input:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(11,110,99,0.12);
        }
        .form-hint { margin-top: 5px; font-size: 12px; color: var(--text-faint); }

        /* Password toggle */
        .pwd-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-faint);
            padding: 4px;
            display: flex;
            align-items: center;
            border-radius: var(--radius-sm);
            transition: color 0.15s;
        }
        .pwd-toggle:hover { color: var(--text-muted); }
        .form-input.has-toggle { padding-right: 38px; }

        /* Error box */
        .error-box {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding: 12px 14px;
            background: var(--error-bg);
            border: 1px solid var(--error-bd);
            color: var(--error);
            border-radius: var(--radius-sm);
            font-size: 14px;
        }

        /* Buttons */
        .btn-row { margin-top: 24px; display: flex; gap: 10px; }
        .btn-primary {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            background: var(--primary);
            color: #fff;
            border: none;
            padding: 11px 20px;
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: background 0.15s, transform 0.15s;
        }
        .btn-primary:hover { background: var(--primary-h); }
        .btn-primary:active { transform: scale(0.98); }
        .btn-ghost {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: var(--text-muted);
            background: var(--surface);
            border: 1px solid var(--border);
            padding: 10px 18px;
            border-radius: var(--radius-sm);
            font-size: 14px;
            font-weight: 500;
            transition: all 0.15s;
        }
        .btn-ghost:hover { color: var(--text); border-color: rgba(0,0,0,0.15); background: var(--surface2); }

        /* Bottom link */
        .bottom-link {
            margin-top: 20px;
            text-align: center;
            font-size: 14px;
            color: var(--text-muted);
        }
        .bottom-link a { color: var(--primary); font-weight: 500; }
        .bottom-link a:hover { color: var(--primary-h); text-decoration: underline; }

        /* Divider */
        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 20px 0;
            color: var(--text-faint);
            font-size: 12px;
        }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--border); }

        @media (max-width: 768px) {
            .nav { padding: 0 16px; }
            .nav-links { display: none; }
            .card-top { padding: 24px 20px 16px; }
            .card-body { padding: 20px 20px 24px; }
        }
    </style>
</head>
<body>

<!-- Nav -->
<nav class="nav">
    <div class="nav-brand">
        <div class="nav-logo" aria-hidden="true">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2 3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 0 1-8 0"/>
            </svg>
        </div>
        <span class="nav-brand-name">民大二手平台</span>
    </div>
    <ul class="nav-links">
        <li><a href="${pageContext.request.contextPath}/index.jsp">首页</a></li>
        <li><a href="${pageContext.request.contextPath}/login">登录</a></li>
    </ul>
    <div class="nav-right"></div>
</nav>

<div class="page-wrapper">
    <div class="register-card">
        <div class="card-top">
            <div class="card-logo">
                <div class="card-logo-icon">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <span class="card-logo-text">民大二手交易平台</span>
            </div>
            <h1>创建账号</h1>
            <p>注册后即可发布和管理自己的商品。</p>
        </div>

        <div class="card-body">
            <% if (request.getAttribute("errorMsg") != null) { %>
                <div class="error-box">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    <%= request.getAttribute("errorMsg") %>
                </div>
            <% } %>

            <form action="${pageContext.request.contextPath}/register" method="post" novalidate>

                <div class="form-item">
                    <label for="studentOrStaffNo">学号 / 工号 <span class="required" aria-hidden="true">*</span></label>
                    <div class="input-wrap">
                        <span class="input-icon">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="2" y="5" width="20" height="14" rx="2"/><line x1="2" y1="10" x2="22" y2="10"/></svg>
                        </span>
                        <input id="studentOrStaffNo" class="form-input" type="text" name="studentOrStaffNo" placeholder="请输入学号或工号" required
                               value="<%= request.getParameter("studentOrStaffNo") == null ? "" : request.getParameter("studentOrStaffNo") %>">
                    </div>
                </div>

                <div class="form-item">
                    <label for="realName">真实姓名 <span class="required" aria-hidden="true">*</span></label>
                    <div class="input-wrap">
                        <span class="input-icon">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        </span>
                        <input id="realName" class="form-input" type="text" name="realName" placeholder="请输入真实姓名" required
                               value="<%= request.getParameter("realName") == null ? "" : request.getParameter("realName") %>">
                    </div>
                </div>

                <div class="form-item">
                    <label for="nickname">昵称 <span style="color:var(--text-faint);font-weight:400;font-size:12px;">（选填）</span></label>
                    <div class="input-wrap">
                        <span class="input-icon">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><circle cx="12" cy="8" r="4"/><path d="M6 20v-2a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v2"/></svg>
                        </span>
                        <input id="nickname" class="form-input" type="text" name="nickname" placeholder="设置一个昵称（可留空）"
                               value="<%= request.getParameter("nickname") == null ? "" : request.getParameter("nickname") %>">
                    </div>
                </div>

                <div class="form-item">
                    <label for="password">密码 <span class="required" aria-hidden="true">*</span></label>
                    <div class="input-wrap">
                        <span class="input-icon">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input id="password" class="form-input has-toggle" type="password" name="password" placeholder="至少 6 位字符" required>
                        <button type="button" class="pwd-toggle" onclick="togglePwd('password', this)" aria-label="显示/隐藏密码">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                    <div class="form-hint">建议至少 6 位，包含字母和数字更安全。</div>
                </div>

                <div class="form-item">
                    <label for="confirmPassword">确认密码 <span class="required" aria-hidden="true">*</span></label>
                    <div class="input-wrap">
                        <span class="input-icon">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                        </span>
                        <input id="confirmPassword" class="form-input has-toggle" type="password" name="confirmPassword" placeholder="再次输入密码" required>
                        <button type="button" class="pwd-toggle" onclick="togglePwd('confirmPassword', this)" aria-label="显示/隐藏确认密码">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </button>
                    </div>
                </div>

                <div class="btn-row">
                    <button type="submit" class="btn-primary">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="8.5" cy="7" r="4"/><line x1="20" y1="8" x2="20" y2="14"/><line x1="23" y1="11" x2="17" y2="11"/></svg>
                        立即注册
                    </button>
                    <a href="${pageContext.request.contextPath}/login" class="btn-ghost">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><polyline points="15 18 9 12 15 6"/></svg>
                        返回登录
                    </a>
                </div>
            </form>

            <div class="divider">或</div>

            <div class="bottom-link">
                已有账号？<a href="${pageContext.request.contextPath}/login">立即登录</a>
            </div>
        </div>
    </div>
</div>

<script>
function togglePwd(inputId, btn) {
    const input = document.getElementById(inputId);
    const isText = input.type === 'text';
    input.type = isText ? 'password' : 'text';
    btn.innerHTML = isText
        ? '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/><path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/><line x1="1" y1="1" x2="23" y2="23"/></svg>'
        : '<svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>';
}
</script>

</body>
</html>
