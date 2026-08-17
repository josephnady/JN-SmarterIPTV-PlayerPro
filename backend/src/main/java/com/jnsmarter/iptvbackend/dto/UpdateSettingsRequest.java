package com.jnsmarter.iptvbackend.dto;

public class UpdateSettingsRequest {

    private Boolean autoplayLast;
    private Long lastChannelId;

    public Boolean getAutoplayLast() { return autoplayLast; }
    public void setAutoplayLast(Boolean autoplayLast) { this.autoplayLast = autoplayLast; }

    public Long getLastChannelId() { return lastChannelId; }
    public void setLastChannelId(Long lastChannelId) { this.lastChannelId = lastChannelId; }
}
