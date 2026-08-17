package com.jnsmarter.iptvbackend.controller;

import com.jnsmarter.iptvbackend.dto.AddM3uRequest;
import com.jnsmarter.iptvbackend.dto.AddXtreamRequest;
import com.jnsmarter.iptvbackend.dto.ChannelDto;
import com.jnsmarter.iptvbackend.dto.PlaylistSummaryDto;
import com.jnsmarter.iptvbackend.exception.ApiException;
import com.jnsmarter.iptvbackend.service.PlaylistService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.List;

@RestController
@RequestMapping("/api/playlists")
public class PlaylistController {

    private final PlaylistService playlistService;

    public PlaylistController(PlaylistService playlistService) {
        this.playlistService = playlistService;
    }

    @GetMapping
    public List<PlaylistSummaryDto> list() {
        return playlistService.listAll();
    }

    @PostMapping("/m3u")
    public PlaylistSummaryDto addFromUrl(@Valid @RequestBody AddM3uRequest request) {
        return playlistService.createFromM3uUrl(request.getName(), request.getUrl(), request.getEpgUrl());
    }

    @PostMapping(value = "/m3u/upload", consumes = "multipart/form-data")
    public PlaylistSummaryDto addFromUpload(@RequestParam String name,
                                             @RequestParam MultipartFile file,
                                             @RequestParam(required = false) MultipartFile epgFile) {
        try {
            String m3uText = new String(file.getBytes(), StandardCharsets.UTF_8);
            String epgText = (epgFile != null && !epgFile.isEmpty())
                    ? new String(epgFile.getBytes(), StandardCharsets.UTF_8) : null;
            return playlistService.createFromM3uUpload(name, m3uText, epgText);
        } catch (IOException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Could not read the uploaded file: " + e.getMessage());
        }
    }

    @PostMapping("/xtream")
    public PlaylistSummaryDto addFromXtream(@Valid @RequestBody AddXtreamRequest request) {
        return playlistService.createFromXtream(request.getName(), request.getHost(), request.getUsername(), request.getPassword());
    }

    @PostMapping("/{id}/refresh")
    public PlaylistSummaryDto refresh(@PathVariable Long id) {
        return playlistService.refresh(id);
    }

    @DeleteMapping("/{id}")
    public void delete(@PathVariable Long id) {
        playlistService.delete(id);
    }

    @GetMapping("/{id}/channels")
    public List<ChannelDto> channels(@PathVariable Long id,
                                      @RequestParam(required = false) String search,
                                      @RequestParam(required = false) String group,
                                      @RequestParam(defaultValue = "false") boolean favoritesOnly) {
        return playlistService.listChannels(id, search, group, favoritesOnly);
    }

    @GetMapping("/{id}/groups")
    public List<String> groups(@PathVariable Long id) {
        return playlistService.listGroups(id);
    }
}
