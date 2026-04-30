<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>错误 — 民大二手交易平台</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg:       #f4f3ef;
            --surface:  #ffffff;
            --border:   rgba(0,0,0,0.09);
            --text:     #1a1a1a;
            --muted:    #737373;
            --primary:  #0b6e63;
            --primary-h:#085c52;
            --error-bg: #fff1f0;
            --error-bd: #ffc5c5;
            --error-tx: #b91c1c;
            --radius:   12px;
            --font:     'Plus Jakarta Sans','PingFang SC','Microsoft YaHei',sans-serif;
            --shadow:   0 8px 32px rgba(0,0,0,0.08);
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { -webkit-font-smoothing: antialiased; }
        body {
            font-family: var(--font);
            background: var(--bg);
            color: var(--text);
            min-height: 100dvh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 24px;
        }
        .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            box-shadow: var(--shadow);
            padding: 40px 36px;
            max-width: 500px;
            width: 100%;
            text-align: center;
        }
        .icon { font-size: 48px; margin-bottom: 20px; }
        .card h1 { font-size: 20px; font-weight: 700; margin-bottom: 12px; color: var(--error-tx); }
        .error-box {
            background: var(--error-bg);
            border: 1px solid var(--error-bd);
            color: var(--error-tx);
            padding: 13px 16px;
            border-radius: 9px;
            font-size: 14px;
            line-height: 1.7;
            text-align: left;
            margin-bottom: 24px;
        }
        .btn-back {
            display: inline-block;
            padding: 10px 24px;
            background: var(--primary);
            color: #fff;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            font-family: var(--font);
            text-decoration: none;
            transition: background 0.15s;
        }
        .btn-back:hover { background: var(--primary-h); }
    </style>
</head>
<body>
    <div class="card">
        <div class="icon">⚠️</div>
        <h1>操作失败</h1>
        <div class="error-box">${errorMsg}</div>
        <a class="btn-back" href="javascript:history.back()">返回上一页</a>
    </div>
</body>
</html>
