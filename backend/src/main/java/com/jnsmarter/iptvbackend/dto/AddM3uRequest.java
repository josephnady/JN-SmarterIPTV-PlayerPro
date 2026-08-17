package com.jnsmarter.iptvbackend.dto;

import jakarta.validation.constraints.NotBlank;

public class AddM3uRequest {

    @NotBlank(message = "name is required")
    private String name;

    @NotBlank(message = "url is required")
    private String url;

    private String epgUrl;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getUrl() { return url; }
    public void setUrl(String url) { this.url = url; }

    public String getEpgUrl() { return epgUrl; }
    public void setEpgUrl(String epgUrl) { this.epgUrl = epgUrl; }
}
