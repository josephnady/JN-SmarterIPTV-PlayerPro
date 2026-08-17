package com.jnsmarter.iptvbackend.dto;

public record SettingsDto(
        boolean autoplayLast,
        Long lastChannelId
) {}
