package com.jnsmarter.iptvbackend.service;

import com.jnsmarter.iptvbackend.dto.SettingsDto;
import com.jnsmarter.iptvbackend.dto.UpdateSettingsRequest;
import com.jnsmarter.iptvbackend.model.AppSettings;
import com.jnsmarter.iptvbackend.model.Channel;
import com.jnsmarter.iptvbackend.repository.AppSettingsRepository;
import com.jnsmarter.iptvbackend.repository.ChannelRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SettingsService {

    private final AppSettingsRepository settingsRepository;
    private final ChannelRepository channelRepository;

    public SettingsService(AppSettingsRepository settingsRepository, ChannelRepository channelRepository) {
        this.settingsRepository = settingsRepository;
        this.channelRepository = channelRepository;
    }

    @Transactional
    public SettingsDto get() {
        return toDto(load());
    }

    @Transactional
    public SettingsDto update(UpdateSettingsRequest request) {
        AppSettings settings = load();

        if (request.getAutoplayLast() != null) {
            settings.setAutoplayLast(request.getAutoplayLast());
        }
        if (request.getLastChannelId() != null) {
            Channel channel = channelRepository.findById(request.getLastChannelId()).orElse(null);
            settings.setLastChannel(channel);
        }

        settingsRepository.save(settings);
        return toDto(settings);
    }

    private AppSettings load() {
        return settingsRepository.findById(1L).orElseGet(() -> settingsRepository.save(new AppSettings()));
    }

    private SettingsDto toDto(AppSettings s) {
        Long lastId = s.getLastChannel() != null ? s.getLastChannel().getId() : null;
        return new SettingsDto(s.isAutoplayLast(), lastId);
    }
}
