package com.jnsmarter.iptvbackend.model;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Lob;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "playlists")
public class Playlist {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PlaylistType type;

    /** M3U_URL only — lets /refresh re-fetch the playlist. */
    private String sourceUrl;

    /** M3U_URL / M3U_FILE only — lets /refresh re-fetch the guide. */
    private String epgUrl;

    /** Last-fetched XMLTV document, used to answer EPG lookups. */
    @Lob
    @Column(columnDefinition = "CLOB")
    private String epgRaw;

    private String xtreamHost;
    private String xtreamUsername;

    /** NOTE: stored in plain text for simplicity. Encrypt this column before any real deployment. */
    private String xtreamPassword;

    @Column(nullable = false)
    private Instant addedAt = Instant.now();

    @OneToMany(mappedBy = "playlist", cascade = CascadeType.ALL, orphanRemoval = true, fetch = FetchType.LAZY)
    private List<Channel> channels = new ArrayList<>();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public PlaylistType getType() { return type; }
    public void setType(PlaylistType type) { this.type = type; }

    public String getSourceUrl() { return sourceUrl; }
    public void setSourceUrl(String sourceUrl) { this.sourceUrl = sourceUrl; }

    public String getEpgUrl() { return epgUrl; }
    public void setEpgUrl(String epgUrl) { this.epgUrl = epgUrl; }

    public String getEpgRaw() { return epgRaw; }
    public void setEpgRaw(String epgRaw) { this.epgRaw = epgRaw; }

    public String getXtreamHost() { return xtreamHost; }
    public void setXtreamHost(String xtreamHost) { this.xtreamHost = xtreamHost; }

    public String getXtreamUsername() { return xtreamUsername; }
    public void setXtreamUsername(String xtreamUsername) { this.xtreamUsername = xtreamUsername; }

    public String getXtreamPassword() { return xtreamPassword; }
    public void setXtreamPassword(String xtreamPassword) { this.xtreamPassword = xtreamPassword; }

    public Instant getAddedAt() { return addedAt; }
    public void setAddedAt(Instant addedAt) { this.addedAt = addedAt; }

    public List<Channel> getChannels() { return channels; }
    public void setChannels(List<Channel> channels) { this.channels = channels; }
}
