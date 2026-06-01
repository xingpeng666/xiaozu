package com.minzu.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class BrowseHistory {

    private long id;
    private long userId;
    private long productId;
    private Timestamp browseTime;

    // 关联字段（用于展示）
    private String productTitle;
    private String coverImageUrl;
    private BigDecimal price;
    private String productStatus;

    public BrowseHistory() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public long getProductId() {
        return productId;
    }

    public void setProductId(long productId) {
        this.productId = productId;
    }

    public Timestamp getBrowseTime() {
        return browseTime;
    }

    public void setBrowseTime(Timestamp browseTime) {
        this.browseTime = browseTime;
    }

    public String getProductTitle() {
        return productTitle;
    }

    public void setProductTitle(String productTitle) {
        this.productTitle = productTitle;
    }

    public String getCoverImageUrl() {
        return coverImageUrl;
    }

    public void setCoverImageUrl(String coverImageUrl) {
        this.coverImageUrl = coverImageUrl;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public String getProductStatus() {
        return productStatus;
    }

    public void setProductStatus(String productStatus) {
        this.productStatus = productStatus;
    }
}
