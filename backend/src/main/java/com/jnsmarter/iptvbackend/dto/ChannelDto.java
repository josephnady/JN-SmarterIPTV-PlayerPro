package com.jnsmarter.iptvbackend.dto;

public record ChannelDto(
        Long id,
        String name,
        String logoUrl,
        String groupTitle,
        String tvgId,
        String streamUrl,
        int channelNumber,
        boolean favorite,
        Long playlistId
) {}
