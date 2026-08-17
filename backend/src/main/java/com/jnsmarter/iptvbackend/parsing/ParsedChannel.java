package com.jnsmarter.iptvbackend.parsing;

public record ParsedChannel(
        String name,
        String logoUrl,
        String groupTitle,
        String tvgId,
        String streamUrl,
        int number
) {}
