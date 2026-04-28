-- V6: 功能扩展 - 举报系统 + 消息通知 + 多图上传 + 特色专区 + 自提点
-- ============================================================

-- 1. 违规举报表
CREATE TABLE IF NOT EXISTS reports (
    report_id   INT AUTO_INCREMENT PRIMARY KEY,
    reporter_id INT NOT NULL COMMENT '举报人用户ID',
    product_id  INT NOT NULL COMMENT '被举报商品ID',
    reason      VARCHAR(500) NOT NULL COMMENT '举报原因',
    status      ENUM('PENDING','HANDLED') NOT NULL DEFAULT 'PENDING' COMMENT '处理状态',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_reports_product (product_id),
    KEY idx_reports_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='违规举报表';

-- 2. 消息通知表
CREATE TABLE IF NOT EXISTS notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT NOT NULL COMMENT '接收通知的用户ID',
    content    VARCHAR(500) NOT NULL COMMENT '通知内容',
    is_read    TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已读 0未读 1已读',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    KEY idx_notify_user (user_id, is_read),
    KEY idx_notify_time (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='消息通知表';

-- 3. products 表新增 image_urls（多图URL，逗号分隔）
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS image_urls VARCHAR(1000) DEFAULT NULL COMMENT '多张图片URL，逗号分隔';

-- 4. products 表新增 tags（特色标签，如 graduation）
ALTER TABLE products
    ADD COLUMN IF NOT EXISTS tags VARCHAR(100) DEFAULT NULL COMMENT '商品标签，逗号分隔';

-- 5. 校园自提点位表
CREATE TABLE IF NOT EXISTS pickup_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) NOT NULL COMMENT '自提点名称',
    address     VARCHAR(300) NOT NULL COMMENT '详细地址',
    description VARCHAR(500) COMMENT '描述/备注',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='校园自提点位';

-- 预插入自提点数据（使用 INSERT IGNORE 防止重复）
INSERT IGNORE INTO pickup_locations (name, address, description) VALUES
('图书馆门口', '中央民族大学图书馆正门外', '图书馆是校内最显眼的地标，适合大型物品交接'),
('东区学生食堂门口', '民大东区学生食堂正门外', '东区宿舍区域，人流量大，适合日常小件交易'),
('知行楼一楼大厅', '中央民族大学知行楼一楼', '知行楼位于校园中心区域，交通便利'),
('文华楼西侧', '中央民族大学文华楼西侧入口处', '文华楼为教学主楼，适合课后快速交接'),
('操场南侧入口', '中央民族大学操场南侧大门', '操场区域开阔，适合展示大件商品（如自行车、乐器等）');
