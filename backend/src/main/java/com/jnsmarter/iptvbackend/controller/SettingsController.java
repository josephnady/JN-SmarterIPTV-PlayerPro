package com.jnsmarter.iptvbackend.controller;

import com.jnsmarter.iptvbackend.dto.SettingsDto;
import com.jnsmarter.iptvbackend.dto.UpdateSettingsRequest;
import com.jnsmarter.iptvbackend.service.SettingsService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/settings")
public class SettingsController {

    private final SettingsService settingsService;

    public SettingsController(SettingsService settingsService) {
        this.settingsService = settingsService;
    }

    @GetMapping
    public SettingsDto get() {
        return settingsService.get();
    }

    @PutMapping
    public SettingsDto update(@Valid @RequestBody UpdateSettingsRequest request) {
        return settingsService.update(request);
    }
}
