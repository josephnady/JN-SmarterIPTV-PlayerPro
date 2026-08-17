package com.jnsmarter.iptvbackend.dto;

import java.util.List;

public record EpgResponseDto(
        String nowTitle,
        String nextTitle,
        List<EpgProgrammeDto> programmes
) {}
