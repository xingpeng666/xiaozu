-- V8: 私信功能 - messages 表
-- ============================================================

CREATE TABLE IF NOT EXISTS messages (
    message_id  INT AUTO_INCREMENT PRIMARY KEY,
    sender_id   INT NOT NULL COMMENT '发送者用户ID',
    receiver_id INT NOT NULL COMMENT '接收者用户ID',
    product_id  INT DEFAULT NULL COMMENT '关联商品ID（可为空）',
    content     VARCHAR(2000) NOT NULL COMMENT '消息内容',
    is_read     TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已读：0=未读 1=已读',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    KEY idx_messages_sender (sender_id),
    KEY idx_messages_receiver (receiver_id),
    KEY idx_messages_product (product_id),
    KEY idx_messages_sender_receiver_time (sender_id, receiver_id, created_at),
    KEY idx_messages_receiver_read (receiver_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='私信表';
