-- V8: 私信功能 - conversations + messages 表
-- ============================================================
-- 基于产品关联的会话模型：
--   conversations 表以 (product_id, buyer_id, seller_id) 唯一确定一个会话
--   messages 表通过 conversation_id 关联到会话

-- 1. 会话表（每个商品+买卖双方 生成一个独立会话）
CREATE TABLE IF NOT EXISTS conversations (
    conversation_id BIGINT NOT NULL AUTO_INCREMENT,
    product_id      BIGINT NOT NULL COMMENT '关联商品ID',
    buyer_id        BIGINT NOT NULL COMMENT '买家用户ID',
    seller_id       BIGINT NOT NULL COMMENT '卖家用户ID',
    last_message_at DATETIME DEFAULT NULL COMMENT '最后消息时间',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (conversation_id),
    UNIQUE KEY uk_conversations (product_id, buyer_id, seller_id),
    KEY fk_conversations_buyer (buyer_id),
    KEY fk_conversations_seller (seller_id),
    CONSTRAINT fk_conversations_buyer FOREIGN KEY (buyer_id) REFERENCES users (user_id),
    CONSTRAINT fk_conversations_product FOREIGN KEY (product_id) REFERENCES products (product_id),
    CONSTRAINT fk_conversations_seller FOREIGN KEY (seller_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='会话表';

-- 2. 消息表（每条消息属于一个会话，记录发送者）
CREATE TABLE IF NOT EXISTS messages (
    message_id      BIGINT NOT NULL AUTO_INCREMENT,
    conversation_id BIGINT NOT NULL COMMENT '所属会话ID',
    sender_id       BIGINT NOT NULL COMMENT '发送者用户ID',
    message_type    ENUM('TEXT','IMAGE','SYSTEM') NOT NULL DEFAULT 'TEXT' COMMENT '消息类型',
    message_content TEXT NOT NULL COMMENT '消息内容',
    is_read         TINYINT(1) NOT NULL DEFAULT 0 COMMENT '是否已读',
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '发送时间',
    PRIMARY KEY (message_id),
    KEY fk_messages_sender (sender_id),
    KEY idx_messages_conversation (conversation_id),
    KEY idx_messages_conversation_created (conversation_id, created_at),
    CONSTRAINT fk_messages_conversation FOREIGN KEY (conversation_id) REFERENCES conversations (conversation_id),
    CONSTRAINT fk_messages_sender FOREIGN KEY (sender_id) REFERENCES users (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT='私信表';
