-- V7: 订单纠纷系统 + 举报状态扩展
-- ============================================================

-- 1. 新增纠纷表
CREATE TABLE IF NOT EXISTS disputes (
    dispute_id   INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT NOT NULL COMMENT '关联订单ID',
    applicant_id INT NOT NULL COMMENT '发起纠纷的买家ID',
    reason       VARCHAR(500) NOT NULL COMMENT '纠纷原因',
    status       ENUM('PENDING','REFUND','RELEASE') NOT NULL DEFAULT 'PENDING'
                 COMMENT '状态: PENDING=待处理 REFUND=退款 RELEASE=放行',
    admin_note   VARCHAR(500) DEFAULT NULL COMMENT '管理员备注',
    created_at   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at  TIMESTAMP NULL DEFAULT NULL COMMENT '处理时间',
    KEY idx_disputes_order (order_id),
    KEY idx_disputes_status (status),
    KEY idx_disputes_applicant (applicant_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='订单纠纷表';

-- 2. orders 表新增 DISPUTED / REFUNDED 状态
-- （如果 orders.status 是 ENUM 类型，执行此语句扩展枚举值）
ALTER TABLE orders
    MODIFY COLUMN status ENUM(
        'PENDING','PAID','CONFIRMED','CANCELLED',
        'DISPUTED','REFUNDED'
    ) NOT NULL DEFAULT 'PENDING';

-- 3. reports 表新增 DISMISSED 状态（驳回举报）
ALTER TABLE reports
    MODIFY COLUMN status ENUM('PENDING','HANDLED','DISMISSED')
    NOT NULL DEFAULT 'PENDING' COMMENT '处理状态';
