package com.jnsmarter.iptvbackend.parsing;

public record Programme(
        String tvgId,
        long start,
        Long stop,
        String title,
        String description
) {}
