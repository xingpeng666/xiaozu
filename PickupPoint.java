package com.minzu.entity;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class PickupPoint {

    private long pickupPointId;
    private String pointName;
    private String campusArea;
    private String addressDetail;
    private String contactPhone;
    private String openTimeDesc;
    private BigDecimal longitude;
    private BigDecimal latitude;
    private boolean isEnabled;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public PickupPoint() {
    }

    public long getPickupPointId() {
        return pickupPointId;
    }

    public void setPickupPointId(long pickupPointId) {
        this.pickupPointId = pickupPointId;
    }

    public String getPointName() {
        return pointName;
    }

    public void setPointName(String pointName) {
        this.pointName = pointName;
    }

    public String getCampusArea() {
        return campusArea;
    }

    public void setCampusArea(String campusArea) {
        this.campusArea = campusArea;
    }

    public String getAddressDetail() {
        return addressDetail;
    }

    public void setAddressDetail(String addressDetail) {
        this.addressDetail = addressDetail;
    }

    public String getContactPhone() {
        return contactPhone;
    }

    public void setContactPhone(String contactPhone) {
        this.contactPhone = contactPhone;
    }

    public String getOpenTimeDesc() {
        return openTimeDesc;
    }

    public void setOpenTimeDesc(String openTimeDesc) {
        this.openTimeDesc = openTimeDesc;
    }

    public BigDecimal getLongitude() {
        return longitude;
    }

    public void setLongitude(BigDecimal longitude) {
        this.longitude = longitude;
    }

    public BigDecimal getLatitude() {
        return latitude;
    }

    public void setLatitude(BigDecimal latitude) {
        this.latitude = latitude;
    }

    public boolean getIsEnabled() {
        return isEnabled;
    }

    public void setIsEnabled(boolean isEnabled) {
        this.isEnabled = isEnabled;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
