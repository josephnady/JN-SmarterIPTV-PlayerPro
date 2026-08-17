package com.jnsmarter.iptvbackend.dto;

import jakarta.validation.constraints.NotBlank;

public class AddXtreamRequest {

    @NotBlank(message = "name is required")
    private String name;

    @NotBlank(message = "host is required")
    private String host;

    @NotBlank(message = "username is required")
    private String username;

    @NotBlank(message = "password is required")
    private String password;

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getHost() { return host; }
    public void setHost(String host) { this.host = host; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
}
