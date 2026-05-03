<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>用户注册 - 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300..700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --color-bg: #f7f6f2;
            --color-surface: #ffffff;
            --color-surface-2: #f9f8f5;
            --color-border: oklch(0.2 0.01 80 / 0.14);
            --color-divider: #e8e6e1;
            --color-text: #28251d;
            --color-text-muted: #7a7974;
            --color-text-faint: #bab9b4;
            --color-primary: #01696f;
            --color-primary-hover: #0c4e54;
            --color-primary-bg: #e6f4f4;
            --color-error: #a12c7b;
            --color-error-bg: #f9eef5;
            --color-error-border: #e0ced7;
            --radius-sm: 6px;
            --radius-md: 8px;
            --radius-lg: 12px;
            --radius-xl: 16px;
            --shadow-sm: 0 1px 2px oklch(0.2 0.01 80 / 0.06);
            --shadow-md: 0 4px 16px oklch(0.2 0.01 80 / 0.09);
            --shadow-lg: 0 12px 36px oklch(0.2 0.01 80 / 0.11);
            --font-body: 'Inter', 'PingFang SC', 'Microsoft YaHei', sans-serif;
            --text-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
            --text-sm: clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
            --text-base: clamp(1rem, 0.95rem + 0.25vw, 1.125rem);
            --text-lg: clamp(1.125rem, 1rem + 0.75vw, 1.5rem);
            --text-xl: clamp(1.5rem, 1.2rem + 1.25vw, 2.25rem);
            --transition: 160ms cubic-bezier(0.16, 1, 0.3, 1);
        }
        html { -webkit-font-smoothing: antialiased; }
        body {
            font-family: var(--font-body);
            font-size: var(--text-base);
            color: var(--color-text);
            background: var(--color-bg);
            min-height: 100dvh;
            line-height: 1.6;
        }
        a { color: inherit; text-decoration: none; }
        button, input { font: inherit; color: inherit; }

        /* ── Header ── */
        .header {
            height: 56px;
            background: var(--color-surface);
            border-bottom: 1px solid var(--color-divider);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
            box-shadow: var(--shadow-sm);
        }
        .header-logo {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 15px;
            font-weight: 700;
            color: var(--color-text);
            letter-spacing: -0.2px;
        }
        .header-logo svg { color: var(--color-primary); }
        .header-nav { display: flex; gap: 4px; }
        .header-nav a {
            font-size: var(--text-sm);
            color: var(--color-text-muted);
            padding: 6px 10px;
            border-radius: var(--radius-md);
            display: flex;
            align-items: center;
            gap: 5px;
            transition: background var(--transition), color var(--transition);
        }
        .header-nav a:hover { background: var(--color-surface-2); color: var(--color-text); }

        /* ── Page layout ── */
        .page-wrapper {
            min-height: calc(100dvh - 56px);
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 16px;
        }
        .register-card {
            width: 100%;
            max-width: 460px;
            background: var(--color-surface);
            border-radius: var(--radius-xl);
            border: 1px solid var(--color-border);
            box-shadow: var(--shadow-lg);
            overflow: hidden;
        }

        /* ── Card header ── */
        .card-top {
            padding: 32px 32px 20px;
            border-bottom: 1px solid var(--color-divider);
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
            background: var(--color-primary-bg);
            border-radius: var(--radius-lg);
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--color-primary);
        }
        .card-logo-text { font-size: var(--text-sm); font-weight: 600; color: var(--color-text-muted); }
        .card-top h1 { font-size: var(--text-xl); font-weight: 700; letter-spacing: -0.5px; margin-bottom: 4px; }
        .card-top p { font-size: var(--text-sm); color: var(--color-text-muted); }

        /* ── Form ── */
        .card-body { padding: 28px 32px 32px; }
        .form-item { margin-bottom: 18px; }
        .form-item label {
            display: flex;
            align-items: center;
            gap: 4px;
            margin-bottom: 7px;
            font-size: var(--text-sm);
            font-weight: 500;
            color: var(--color-text);
        }
        .required { color: #e53e3e; font-size: 13px; line-height: 1; }
        .input-wrap { position: relative; }
        .input-icon {
            position: absolute;
            left: 11px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--color-text-faint);
            pointer-events: none;
            display: flex;
        }
        .form-input {
            width: 100%;
            padding: 10px 12px 10px 36px;
            border: 1px solid var(--color-border);
            border-radius: var(--radius-md);
            font-size: var(--text-sm);
            background: var(--color-surface);
            color: var(--color-text);
            outline: none;
            transition: border-color var(--transition), box-shadow var(--transition);
        }
        .form-input.no-icon { padding-left: 12px; }
        .form-input::placeholder { color: var(--color-text-faint); }
        .form-input:hover { border-color: oklch(0.2 0.01 80 / 0.28); }
        .form-input:focus {
            border-color: var(--color-primary);
            box-shadow: 0 0 0 3px oklch(from var(--color-primary) l c h / 0.12);
        }
        .form-hint { margin-top: 5px; font-size: var(--text-xs); color: var(--color-text-faint); }

        /* Password toggle */
        .pwd-toggle {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            cursor: pointer;
            color: var(--color-text-faint);
            padding: 4px;
            display: flex;
            align-items: center;
            border-radius: var(--radius-sm);
            transition: color var(--transition);
        }
        .pwd-toggle:hover { color: var(--color-text-muted); }
        .form-input.has-toggle { padding-right: 38px; }

        /* Error box */
        .error-box {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 18px;
            padding: 12px 14px;
            background: var(--color-error-bg);
            border: 1px solid var(--color-error-border);
            color: var(--color-error);
            border-radius: var(--radius-md);
            font-size: var(--text-sm);
        }

        /* Buttons */
        .btn-row { margin-top: 24px; display: flex; gap: 10px; }
        .btn-primary {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            background: var(--color-primary);
            color: #fff;
            border: none;
            padding: 11px 20px;
            border-radius: var(--radius-md);
            font-size: var(--text-sm);
            font-weight: 600;
            cursor: pointer;
            transition: background var(--transition), transform var(--transition);
        }
        .btn-primary:hover { background: var(--color-primary-hover); }
        .btn-primary:active { transform: scale(0.98); }
        .btn-ghost {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            color: var(--color-text-muted);
            background: var(--color-surface);
            border: 1px solid var(--color-border);
            padding: 10px 18px;
            border-radius: var(--radius-md);
            font-size: var(--text-sm);
            font-weight: 500;
            transition: all var(--transition);
        }
        .btn-ghost:hover { color: var(--color-text); border-color: oklch(0.2 0.01 80 / 0.28); background: var(--color-surface-2); }

        /* Bottom link */
        .bottom-link {
            margin-top: 20px;
            text-align: center;
            font-size: var(--text-sm);
            color: var(--color-text-muted);
        }
        .bottom-link a { color: var(--color-primary); font-weight: 500; }
        .bottom-link a:hover { color: var(--color-primary-hover); text-decoration: underline; }

        /* Divider */
        .divider {
            display: flex;
            align-items: center;
            gap: 12px;
            margin: 20px 0;
            color: var(--color-text-faint);
            font-size: var(--text-xs);
        }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: var(--color-divider); }
    </style>
</head>
<body>

<!-- Header -->
<header class="header">
    <a href="${pageContext.request.contextPath}/index.jsp" class="header-logo">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        <span>民大二手交易平台</span>
    </a>
    <nav class="header-nav">
        <a href="${pageContext.request.contextPath}/index.jsp">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            首页
        </a>
        <a href="${pageContext.request.contextPath}/login">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/><polyline points="10 17 15 12 10 7"/><line x1="15" y1="12" x2="3" y2="12"/></svg>
            登录
        </a>
    </nav>
</header>

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
                    <label for="nickname">昵称 <span style="color:var(--color-text-faint);font-weight:400;font-size:var(--text-xs);">（选填）</span></label>
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
