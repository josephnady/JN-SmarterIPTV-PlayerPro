package com.jnsmarter.iptvbackend.dto;

import java.time.Instant;

public record PlaylistSummaryDto(
        Long id,
        String name,
        String type,
        int channelCount,
        Instant addedAt,
        boolean refreshable
) {}
