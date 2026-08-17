package com.jnsmarter.iptvbackend.repository;

import com.jnsmarter.iptvbackend.model.Channel;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChannelRepository extends JpaRepository<Channel, Long> {

    List<Channel> findByPlaylistIdOrderByChannelNumberAsc(Long playlistId);

    List<Channel> findByFavoriteTrue();

    long countByPlaylistId(Long playlistId);

    void deleteByPlaylistId(Long playlistId);
}
