package com.jnsmarter.iptvbackend.service;

import com.jnsmarter.iptvbackend.client.HttpFetchClient;
import com.jnsmarter.iptvbackend.client.XtreamClient;
import com.jnsmarter.iptvbackend.dto.ChannelDto;
import com.jnsmarter.iptvbackend.dto.PlaylistSummaryDto;
import com.jnsmarter.iptvbackend.exception.ApiException;
import com.jnsmarter.iptvbackend.model.Channel;
import com.jnsmarter.iptvbackend.model.Playlist;
import com.jnsmarter.iptvbackend.model.PlaylistType;
import com.jnsmarter.iptvbackend.parsing.M3uParser;
import com.jnsmarter.iptvbackend.parsing.ParsedChannel;
import com.jnsmarter.iptvbackend.repository.ChannelRepository;
import com.jnsmarter.iptvbackend.repository.PlaylistRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class PlaylistService {

    private final PlaylistRepository playlistRepository;
    private final ChannelRepository channelRepository;
    private final HttpFetchClient httpFetchClient;
    private final XtreamClient xtreamClient;
    private final EpgCacheService epgCacheService;

    public PlaylistService(PlaylistRepository playlistRepository,
                            ChannelRepository channelRepository,
                            HttpFetchClient httpFetchClient,
                            XtreamClient xtreamClient,
                            EpgCacheService epgCacheService) {
        this.playlistRepository = playlistRepository;
        this.channelRepository = channelRepository;
        this.httpFetchClient = httpFetchClient;
        this.xtreamClient = xtreamClient;
        this.epgCacheService = epgCacheService;
    }

    @Transactional
    public PlaylistSummaryDto createFromM3uUrl(String name, String url, String epgUrl) {
        String m3uText;
        try {
            m3uText = httpFetchClient.fetchText(url);
        } catch (Exception e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Could not fetch playlist: " + e.getMessage());
        }

        List<ParsedChannel> parsed = M3uParser.parse(m3uText);
        if (parsed.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "No channels found in that playlist");
        }

        String epgRaw = null;
        if (epgUrl != null && !epgUrl.isBlank()) {
            try {
                epgRaw = httpFetchClient.fetchText(epgUrl);
            } catch (Exception ignored) {
                // EPG is optional — the playlist still gets added without it.
            }
        }

        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setType(PlaylistType.M3U_URL);
        playlist.setSourceUrl(url);
        playlist.setEpgUrl(epgUrl);
        playlist.setEpgRaw(epgRaw);
        playlist = playlistRepository.save(playlist);
        attachChannels(playlist, parsed, List.of());

        return toSummary(playlist);
    }

    @Transactional
    public PlaylistSummaryDto createFromM3uUpload(String name, String m3uText, String epgText) {
        List<ParsedChannel> parsed = M3uParser.parse(m3uText);
        if (parsed.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "No channels found in that playlist file");
        }

        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setType(PlaylistType.M3U_FILE);
        playlist.setEpgRaw(epgText);
        playlist = playlistRepository.save(playlist);
        attachChannels(playlist, parsed, List.of());

        return toSummary(playlist);
    }

    @Transactional
    public PlaylistSummaryDto createFromXtream(String name, String host, String username, String password) {
        XtreamClient.XtreamResult result;
        try {
            result = xtreamClient.login(host, username, password);
        } catch (IllegalStateException | IllegalArgumentException e) {
            throw new ApiException(HttpStatus.BAD_REQUEST, e.getMessage());
        } catch (Exception e) {
            throw new ApiException(HttpStatus.BAD_GATEWAY, "Could not reach that Xtream server: " + e.getMessage());
        }

        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setType(PlaylistType.XTREAM);
        playlist.setXtreamHost(xtreamClient.normalizeHost(host));
        playlist.setXtreamUsername(username);
        playlist.setXtreamPassword(password);
        playlist.setEpgRaw(result.epgRaw());
        playlist = playlistRepository.save(playlist);
        attachChannels(playlist, result.channels(), List.of());

        return toSummary(playlist);
    }

    @Transactional
    public PlaylistSummaryDto refresh(Long playlistId) {
        Playlist playlist = getOrThrow(playlistId);

        List<ParsedChannel> parsed;
        String epgRaw = playlist.getEpgRaw();

        switch (playlist.getType()) {
            case XTREAM -> {
                XtreamClient.XtreamResult result;
                try {
                    result = xtreamClient.login(playlist.getXtreamHost(), playlist.getXtreamUsername(), playlist.getXtreamPassword());
                } catch (Exception e) {
                    throw new ApiException(HttpStatus.BAD_GATEWAY, "Refresh failed: " + e.getMessage());
                }
                parsed = result.channels();
                epgRaw = result.epgRaw();
            }
            case M3U_URL -> {
                try {
                    parsed = M3uParser.parse(httpFetchClient.fetchText(playlist.getSourceUrl()));
                } catch (Exception e) {
                    throw new ApiException(HttpStatus.BAD_GATEWAY, "Refresh failed: " + e.getMessage());
                }
                if (playlist.getEpgUrl() != null && !playlist.getEpgUrl().isBlank()) {
                    try {
                        epgRaw = httpFetchClient.fetchText(playlist.getEpgUrl());
                    } catch (Exception ignored) {
                        // keep the previously cached EPG if the re-fetch fails
                    }
                }
            }
            default -> throw new ApiException(HttpStatus.BAD_REQUEST,
                    "This playlist was added from a local file and has no source to refresh from — remove and re-add it instead.");
        }

        if (parsed.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_GATEWAY, "Refresh returned no channels — keeping the existing list");
        }

        // Preserve favorites across the refresh by matching on stream URL.
        List<String> previouslyFavorited = channelRepository.findByPlaylistIdOrderByChannelNumberAsc(playlistId).stream()
                .filter(Channel::isFavorite)
                .map(Channel::getStreamUrl)
                .toList();

        channelRepository.deleteByPlaylistId(playlistId);
        playlist.setEpgRaw(epgRaw);
        playlist = playlistRepository.save(playlist);
        epgCacheService.invalidate(playlistId);

        attachChannels(playlist, parsed, previouslyFavorited);

        return toSummary(playlist);
    }

    @Transactional
    public void delete(Long playlistId) {
        getOrThrow(playlistId);
        playlistRepository.deleteById(playlistId);
        epgCacheService.invalidate(playlistId);
    }

    @Transactional(readOnly = true)
    public List<PlaylistSummaryDto> listAll() {
        return playlistRepository.findAll().stream().map(this::toSummary).toList();
    }

    @Transactional(readOnly = true)
    public List<ChannelDto> listChannels(Long playlistId, String search, String group, boolean favoritesOnly) {
        getOrThrow(playlistId);
        String searchLower = search == null ? null : search.toLowerCase();

        return channelRepository.findByPlaylistIdOrderByChannelNumberAsc(playlistId).stream()
                .filter(c -> !favoritesOnly || c.isFavorite())
                .filter(c -> searchLower == null || searchLower.isBlank() || c.getName().toLowerCase().contains(searchLower))
                .filter(c -> group == null || group.isBlank() || group.equals(c.getGroupTitle()))
                .map(this::toDto)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<String> listGroups(Long playlistId) {
        getOrThrow(playlistId);
        return channelRepository.findByPlaylistIdOrderByChannelNumberAsc(playlistId).stream()
                .map(Channel::getGroupTitle)
                .distinct()
                .sorted()
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ChannelDto> listFavorites() {
        return channelRepository.findByFavoriteTrue().stream().map(this::toDto).toList();
    }

    @Transactional
    public ChannelDto toggleFavorite(Long channelId) {
        Channel channel = channelRepository.findById(channelId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Channel not found"));
        channel.setFavorite(!channel.isFavorite());
        channelRepository.save(channel);
        return toDto(channel);
    }

    private void attachChannels(Playlist playlist, List<ParsedChannel> parsed, List<String> favoritedStreamUrls) {
        List<Channel> entities = new ArrayList<>();
        for (ParsedChannel pc : parsed) {
            Channel c = new Channel();
            c.setPlaylist(playlist);
            c.setName(pc.name());
            c.setLogoUrl(pc.logoUrl());
            c.setGroupTitle(pc.groupTitle() == null || pc.groupTitle().isBlank() ? "Uncategorized" : pc.groupTitle());
            c.setTvgId(pc.tvgId());
            c.setStreamUrl(pc.streamUrl());
            c.setChannelNumber(pc.number());
            c.setFavorite(favoritedStreamUrls.contains(pc.streamUrl()));
            entities.add(c);
        }
        channelRepository.saveAll(entities);
    }

    private Playlist getOrThrow(Long id) {
        return playlistRepository.findById(id)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Playlist not found"));
    }

    private PlaylistSummaryDto toSummary(Playlist p) {
        long count = channelRepository.countByPlaylistId(p.getId());
        boolean refreshable = p.getType() != PlaylistType.M3U_FILE;
        return new PlaylistSummaryDto(p.getId(), p.getName(), p.getType().name(), (int) count, p.getAddedAt(), refreshable);
    }

    private ChannelDto toDto(Channel c) {
        return new ChannelDto(c.getId(), c.getName(), c.getLogoUrl(), c.getGroupTitle(), c.getTvgId(),
                c.getStreamUrl(), c.getChannelNumber(), c.isFavorite(), c.getPlaylist().getId());
    }
}
