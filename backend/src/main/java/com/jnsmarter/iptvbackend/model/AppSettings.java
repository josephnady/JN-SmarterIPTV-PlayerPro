package com.jnsmarter.iptvbackend.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "app_settings")
public class AppSettings {

    /** Always 1 — this table only ever holds a single row (single-user, local app). */
    @Id
    private Long id = 1L;

    @Column(nullable = false)
    private boolean autoplayLast = true;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "last_channel_id")
    private Channel lastChannel;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public boolean isAutoplayLast() { return autoplayLast; }
    public void setAutoplayLast(boolean autoplayLast) { this.autoplayLast = autoplayLast; }

    public Channel getLastChannel() { return lastChannel; }
    public void setLastChannel(Channel lastChannel) { this.lastChannel = lastChannel; }
}
