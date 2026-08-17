package com.jnsmarter.iptvbackend.service;

import com.jnsmarter.iptvbackend.dto.EpgProgrammeDto;
import com.jnsmarter.iptvbackend.dto.EpgResponseDto;
import com.jnsmarter.iptvbackend.exception.ApiException;
import com.jnsmarter.iptvbackend.model.Channel;
import com.jnsmarter.iptvbackend.parsing.Programme;
import com.jnsmarter.iptvbackend.parsing.XmltvParser;
import com.jnsmarter.iptvbackend.repository.ChannelRepository;
import com.jnsmarter.iptvbackend.repository.PlaylistRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.stream.Collectors;

@Service
public class EpgCacheService {

    private final PlaylistRepository playlistRepository;
    private final ChannelRepository channelRepository;

    /** playlistId -> (tvgId -> programmes). Rebuilt lazily; cleared on refresh/delete. */
    private final Map<Long, Map<String, List<Programme>>> cache = new ConcurrentHashMap<>();

    public EpgCacheService(PlaylistRepository playlistRepository, ChannelRepository channelRepository) {
        this.playlistRepository = playlistRepository;
        this.channelRepository = channelRepository;
    }

    public void invalidate(Long playlistId) {
        cache.remove(playlistId);
    }

    public EpgResponseDto forChannel(Long channelId) {
        Channel channel = channelRepository.findById(channelId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Channel not found"));

        if (channel.getTvgId() == null || channel.getTvgId().isBlank()) {
            return new EpgResponseDto(null, null, List.of());
        }

        Long playlistId = channel.getPlaylist().getId();
        Map<String, List<Programme>> byTvgId = cache.computeIfAbsent(playlistId, id -> {
            String epgRaw = playlistRepository.findById(id).map(p -> p.getEpgRaw()).orElse(null);
            return XmltvParser.parse(epgRaw).stream().collect(Collectors.groupingBy(Programme::tvgId));
        });

        List<Programme> programmes = byTvgId.getOrDefault(channel.getTvgId(), List.of()).stream()
                .sorted(Comparator.comparingLong(Programme::start))
                .toList();

        if (programmes.isEmpty()) {
            return new EpgResponseDto(null, null, List.of());
        }

        long now = Instant.now().toEpochMilli();
        String nowTitle = null;
        String nextTitle = null;
        List<EpgProgrammeDto> dtos = new ArrayList<>();

        for (Programme p : programmes) {
            boolean isCurrent = p.start() <= now && (p.stop() == null || now < p.stop());
            if (isCurrent) nowTitle = p.title();
            if (nextTitle == null && p.start() > now) nextTitle = p.title();
            dtos.add(new EpgProgrammeDto(p.title(), p.description(), p.start(), p.stop(), isCurrent));
        }

        return new EpgResponseDto(nowTitle, nextTitle, dtos);
    }
}
