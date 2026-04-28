# 二手交易平台 (Minzu Secondhand)

> 基于 Java Servlet + JSP + MySQL 构建的校园二手商品交易平台，支持用户注册审核、商品发布与管理、订单交易、站内消息、商品评价、举报、通知等完整功能。

---

## 📌 项目简介

本平台面向校园用户，提供一个安全、便捷的二手物品流通渠道。用户注册后需经管理员审核方可发布商品，支持买卖双方站内沟通、订单确认、交易完成后互评等完整交易流程，管理员可对用户、商品及举报进行全面管理，保障平台交易环境的健康有序。

---

## ✨ 功能特性

### 用户端
- **用户注册 / 登录 / 退出**：支持账号注册，注册后需等待管理员审核激活
- **个人主页**：查看和编辑个人资料
- **商品列表浏览**：查看平台上所有在售二手商品，支持搜索与分类筛选
- **商品详情查看**：查看商品的详细信息、图片及卖家联系方式
- **发布商品**：审核通过的用户可发布二手商品（含图片上传）
- **编辑商品**：修改已发布的商品信息
- **删除商品**：用户可删除自己发布的商品
- **我的商品**：查看自己发布的所有商品列表
- **收藏功能**：收藏感兴趣的商品，随时查看收藏列表
- **订单系统**：下单购买、查看订单状态（待确认、已完成等）、确认收货
- **站内消息**：与买家 / 卖家进行站内私信沟通，支持会话列表与聊天界面
- **商品评价**：交易完成后对商品进行评分和文字评价，查看自己的历史评价
- **举报功能**：对违规商品或用户进行举报
- **消息通知**：接收系统通知（审核结果、订单状态变更等）
- **取货地点**：查看平台预设的校园取货地点信息

### 管理员端
- **管理员面板**：总览平台数据
- **用户审核**：查看待审核用户列表，执行通过或拒绝操作
- **商品审核**：审核用户发布的商品是否合规
- **举报管理**：查看并处理用户举报记录

---

## 🛠️ 技术栈

| 层次 | 技术 |
|------|------|
| 后端 | Java 21 + Servlet 4.0 |
| 前端 | JSP 2.3 + JSTL 1.2 |
| 数据库 | MySQL 8.x |
| 构建工具 | Maven 3.x |
| 部署容器 | Apache Tomcat 9.0（WAR 包部署） |

---

## 📁 项目结构

```
Seconde-hand-trading-platform/
├── db/                             # 数据库初始化 SQL
├── src/
│   └── main/
│       ├── java/
│       │   └── com/minzu/
│       │       ├── entity/         # 实体类 (User, Product, Message, Review)
│       │       ├── servlet/        # 业务逻辑 Servlet
│       │       │   ├── LoginServlet.java
│       │       │   ├── RegisterServlet.java
│       │       │   ├── PublishProductServlet.java
│       │       │   ├── EditProductServlet.java
│       │       │   ├── DeleteProductServlet.java
│       │       │   ├── ProductListServlet.java
│       │       │   ├── ProductDetailServlet.java
│       │       │   ├── FavoriteServlet.java
│       │       │   ├── OrderServlet.java
│       │       │   ├── MessageServlet.java
│       │       │   ├── ReviewServlet.java
│       │       │   ├── ReportServlet.java
│       │       │   ├── NotificationServlet.java
│       │       │   ├── ProfileServlet.java
│       │       │   ├── AdminDashboardServlet.java
│       │       │   ├── AdminUserReviewServlet.java
│       │       │   ├── AdminProductReviewServlet.java
│       │       │   ├── TestDBServlet.java  # 开发调试用，待测试完成后删除
│       │       │   └── ...
│       │       ├── filter/         # 过滤器（登录校验等）
│       │       └── util/           # 工具类（数据库连接等）
│       └── webapp/                 # JSP 页面 & 静态资源
│           ├── index.jsp
│           ├── login.jsp / register.jsp
│           ├── product-list.jsp / product-detail.jsp
│           ├── publish-product.jsp / edit-product.jsp
│           ├── my-products.jsp / my-orders.jsp
│           ├── my-favorites.jsp / my-reviews.jsp
│           ├── messages.jsp / message-chat.jsp
│           ├── notifications.jsp
│           ├── pickup-locations.jsp
│           ├── profile.jsp
│           ├── admin-dashboard.jsp
│           ├── admin-user-review.jsp
│           ├── admin-product-review.jsp
│           ├── admin-reports.jsp
│           └── WEB-INF/
├── pom.xml
└── README.md
```

---

## 🚀 快速开始

### 环境要求

- JDK 21+
- Apache Tomcat 9.0+
- MySQL 8.x
- Maven 3.6+

### 部署步骤

1. **克隆仓库**
   ```bash
   git clone https://github.com/gandipeng/Seconde-hand-trading-platform.git
   cd Seconde-hand-trading-platform
   ```

2. **初始化数据库**

   在 MySQL 中创建数据库并导入 `db/` 目录下的初始化 SQL：
   ```sql
   CREATE DATABASE minzu_secondhand DEFAULT CHARACTER SET utf8mb4;
   USE minzu_secondhand;
   SOURCE db/init.sql;  -- 请以实际 SQL 文件名为准
   ```

3. **配置数据库连接**

   修改 `src/main/java/com/minzu/util/` 下的数据库工具类，填写您的数据库连接信息：
   ```
   URL:      jdbc:mysql://localhost:3306/minzu_secondhand
   Username: your_username
   Password: your_password
   ```

4. **Maven 打包**
   ```bash
   mvn clean package
   ```

5. **部署到 Tomcat**

   将生成的 `target/minzu-secondhand.war` 复制到 Tomcat 9.0 的 `webapps/` 目录，启动 Tomcat 后访问：
   ```
   http://localhost:8080/minzu-secondhand/
   ```

---

## 🔑 默认账户

| 角色 | 说明 |
|------|------|
| 管理员 | 请在数据库中手动插入管理员账户（`role` 字段设为 `admin`） |
| 普通用户 | 注册后由管理员审核激活 |

示例（请根据实际表结构调整）：
```sql
INSERT INTO users (username, password, role, status)
VALUES ('admin', 'your_hashed_password', 'admin', 'active');
```

---

## 📄 许可证

本项目为学习用途开发，暂未设置开源许可证。如需使用，请联系项目作者。
