package com.jnsmarter.iptvbackend.dto;

public record EpgProgrammeDto(
        String title,
        String description,
        long start,
        Long stop,
        boolean current
) {}
