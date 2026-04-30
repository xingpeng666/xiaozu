<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    com.minzu.entity.User loginUser = (com.minzu.entity.User) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    String errMsg = (String) session.getAttribute("errorMsg");
    String sucMsg = (String) session.getAttribute("successMsg");
    session.removeAttribute("errorMsg"); session.removeAttribute("successMsg");
    String uNo       = (String) request.getAttribute("u_no");       if(uNo==null) uNo="";
    String uRealName = (String) request.getAttribute("u_realName"); if(uRealName==null) uRealName="";
    String uNickname = (String) request.getAttribute("u_nickname"); if(uNickname==null) uNickname="";
    String uPhone    = (String) request.getAttribute("u_phone");    if(uPhone==null) uPhone="";
    String uEmail    = (String) request.getAttribute("u_email");    if(uEmail==null) uEmail="";
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>个人信息 — 民大二手交易平台</title>
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
            --warn:       #d97706;
            --warn-hl:    #fef3c7;
            --error-bg:   #fff1f0;
            --error-bd:   #ffc5c5;
            --error-tx:   #b91c1c;
            --success-bg: #f0fdf4;
            --success-bd: #bbf7d0;
            --success-tx: #15803d;
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
        .nav-links a.active { background: var(--primary-hl); color: var(--primary); }
        .nav-links .btn-logout { margin-left: 6px; padding: 6px 14px; background: var(--primary); color: #fff; border-radius: 7px; }
        .nav-links .btn-logout:hover { background: var(--primary-h); color: #fff; }

        .container { max-width: 600px; margin: 36px auto; padding: 0 16px 48px; }
        .page-header { margin-bottom: 28px; }
        .page-header h1 { font-size: 22px; font-weight: 700; }

        .alert {
            padding: 11px 14px; border-radius: 8px; font-size: 13.5px;
            margin-bottom: 18px; display: flex; align-items: flex-start; gap: 8px; line-height: 1.5;
        }
        .alert-error   { background: var(--error-bg);   border: 1px solid var(--error-bd);   color: var(--error-tx); }
        .alert-success { background: var(--success-bg); border: 1px solid var(--success-bd); color: var(--success-tx); }

        .card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); box-shadow: var(--shadow); margin-bottom: 20px;
        }
        .card-header {
            padding: 14px 20px; border-bottom: 1px solid var(--border);
            font-size: 14px; font-weight: 700; color: var(--text);
        }
        .card-body { padding: 20px; }

        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; font-size: 13px; font-weight: 600;
            color: var(--text); margin-bottom: 7px;
        }
        .form-group input {
            width: 100%; padding: 10px 13px;
            border: 1.5px solid var(--border); border-radius: 9px;
            font-size: 14px; font-family: var(--font);
            background: #fafafa; color: var(--text); outline: none;
            transition: border-color 0.18s, box-shadow 0.18s, background 0.18s;
        }
        .form-group input:focus {
            border-color: var(--primary); background: #fff;
            box-shadow: 0 0 0 3px rgba(11,110,99,0.1);
        }
        .form-group input:disabled { background: #f0f0ee; color: var(--text-muted); cursor: not-allowed; }
        .form-group input::placeholder { color: #b0b0b0; }

        .btn {
            padding: 10px 22px; border-radius: 8px; font-size: 14px; font-weight: 600;
            font-family: var(--font); cursor: pointer; border: none; transition: all 0.15s;
        }
        .btn-primary { background: var(--primary); color: #fff; }
        .btn-primary:hover { background: var(--primary-h); }
        .btn-warn { background: var(--warn); color: #fff; }
        .btn-warn:hover { background: #b45309; }
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
        <a href="<%=request.getContextPath()%>/index.jsp">首页</a>
        <a href="<%=request.getContextPath()%>/orders?type=buy">我的订单</a>
        <a href="<%=request.getContextPath()%>/my-reviews">我的评价</a>
        <a href="<%=request.getContextPath()%>/profile" class="active">个人信息</a>
        <a href="<%=request.getContextPath()%>/logout" class="btn-logout">退出</a>
    </div>
</nav>

<div class="container">
    <div class="page-header">
        <h1>个人信息</h1>
    </div>

    <% if(errMsg!=null){ %>
    <div class="alert alert-error"><span>✕</span><span><%=errMsg%></span></div>
    <% } %>
    <% if(sucMsg!=null){ %>
    <div class="alert alert-success"><span>✓</span><span><%=sucMsg%></span></div>
    <% } %>

    <div class="card">
        <div class="card-header">基本资料</div>
        <div class="card-body">
            <form method="post" action="<%=request.getContextPath()%>/profile">
                <div class="form-group">
                    <label>学号 / 工号</label>
                    <input type="text" value="<%=uNo%>" disabled>
                </div>
                <div class="form-group">
                    <label>真实姓名</label>
                    <input type="text" value="<%=uRealName%>" disabled>
                </div>
                <div class="form-group">
                    <label>昵称</label>
                    <input type="text" name="nickname" value="<%=uNickname%>" maxlength="30" placeholder="设置昵称（选填）">
                </div>
                <div class="form-group">
                    <label>手机号</label>
                    <input type="tel" name="phone" value="<%=uPhone%>" maxlength="20" placeholder="联系手机（选填）">
                </div>
                <div class="form-group">
                    <label>邮笱</label>
                    <input type="email" name="email" value="<%=uEmail%>" maxlength="100" placeholder="联系邮笱（选填）">
                </div>
                <button type="submit" class="btn btn-primary">保存基本资料</button>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header">修改密码（不修改则留空）</div>
        <div class="card-body">
            <form method="post" action="<%=request.getContextPath()%>/profile">
                <input type="hidden" name="nickname" value="<%=uNickname%>">
                <input type="hidden" name="phone"    value="<%=uPhone%>">
                <input type="hidden" name="email"    value="<%=uEmail%>">
                <div class="form-group">
                    <label>当前密码</label>
                    <input type="password" name="oldPassword" placeholder="输入当前密码">
                </div>
                <div class="form-group">
                    <label>新密码</label>
                    <input type="password" name="newPassword" placeholder="6-16 位字母/数字">
                </div>
                <div class="form-group">
                    <label>确认新密码</label>
                    <input type="password" name="confirmPassword" placeholder="再次输入新密码">
                </div>
                <button type="submit" class="btn btn-warn">修改密码</button>
            </form>
        </div>
    </div>
</div>

</body>
</html>
