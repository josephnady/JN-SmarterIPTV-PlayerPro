package com.jnsmarter.iptvbackend.controller;

import com.jnsmarter.iptvbackend.dto.ChannelDto;
import com.jnsmarter.iptvbackend.dto.EpgResponseDto;
import com.jnsmarter.iptvbackend.service.EpgCacheService;
import com.jnsmarter.iptvbackend.service.PlaylistService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
public class ChannelController {

    private final PlaylistService playlistService;
    private final EpgCacheService epgCacheService;

    public ChannelController(PlaylistService playlistService, EpgCacheService epgCacheService) {
        this.playlistService = playlistService;
        this.epgCacheService = epgCacheService;
    }

    @GetMapping("/favorites")
    public List<ChannelDto> favorites() {
        return playlistService.listFavorites();
    }

    @PostMapping("/channels/{id}/favorite")
    public ChannelDto toggleFavorite(@PathVariable Long id) {
        return playlistService.toggleFavorite(id);
    }

    @GetMapping("/channels/{id}/epg")
    public EpgResponseDto epg(@PathVariable Long id) {
        return epgCacheService.forChannel(id);
    }
}
