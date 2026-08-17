package com.jnsmarter.iptvbackend.repository;

import com.jnsmarter.iptvbackend.model.Playlist;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PlaylistRepository extends JpaRepository<Playlist, Long> {
}
