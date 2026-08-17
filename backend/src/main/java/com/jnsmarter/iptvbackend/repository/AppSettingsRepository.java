package com.jnsmarter.iptvbackend.repository;

import com.jnsmarter.iptvbackend.model.AppSettings;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AppSettingsRepository extends JpaRepository<AppSettings, Long> {
}
