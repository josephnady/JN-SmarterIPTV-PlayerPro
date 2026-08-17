package com.jnsmarter.iptvbackend.client;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.jnsmarter.iptvbackend.parsing.ParsedChannel;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class XtreamClient {

    private final HttpFetchClient http;
    private final ObjectMapper mapper = new ObjectMapper();

    public XtreamClient(HttpFetchClient http) {
        this.http = http;
    }

    public record XtreamResult(List<ParsedChannel> channels, String epgRaw) {}

    public String normalizeHost(String raw) {
        String h = raw == null ? "" : raw.trim();
        if (h.isEmpty()) return h;
        if (!h.matches("(?i)^https?://.*")) h = "http://" + h;
        while (h.endsWith("/")) h = h.substring(0, h.length() - 1);
        return h;
    }

    public XtreamResult login(String host, String username, String password) throws IOException, InterruptedException {
        String base = normalizeHost(host);
        if (base.isEmpty()) throw new IllegalArgumentException("Host URL is required");

        String u = URLEncoder.encode(username, StandardCharsets.UTF_8);
        String p = URLEncoder.encode(password, StandardCharsets.UTF_8);

        JsonNode auth = mapper.readTree(http.fetchText(base + "/player_api.php?username=" + u + "&password=" + p));
        JsonNode userInfo = auth.get("user_info");
        if (userInfo == null || userInfo.get("auth") == null || userInfo.get("auth").asInt() != 1) {
            String status = (userInfo != null && userInfo.has("status"))
                    ? " (" + userInfo.get("status").asText() + ")" : "";
            throw new IllegalStateException("Login failed — check host, username and password" + status);
        }

        JsonNode categories;
        try {
            categories = mapper.readTree(http.fetchText(
                    base + "/player_api.php?username=" + u + "&password=" + p + "&action=get_live_categories"));
        } catch (Exception e) {
            categories = mapper.createArrayNode();
        }
        Map<String, String> categoryNames = new HashMap<>();
        if (categories.isArray()) {
            for (JsonNode c : categories) {
                categoryNames.put(c.path("category_id").asText(), c.path("category_name").asText("Live"));
            }
        }

        JsonNode streams = mapper.readTree(http.fetchText(
                base + "/player_api.php?username=" + u + "&password=" + p + "&action=get_live_streams"));
        if (!streams.isArray() || streams.size() == 0) {
            throw new IllegalStateException("Signed in, but no live channels were returned for this account");
        }

        List<ParsedChannel> channels = new ArrayList<>();
        int i = 0;
        for (JsonNode s : streams) {
            i++;
            String streamId = s.path("stream_id").asText();
            String name = s.path("name").asText("Channel " + streamId);
            String logo = s.path("stream_icon").asText("");
            String categoryId = s.path("category_id").asText();
            String group = categoryNames.getOrDefault(categoryId, "Live");
            String epgChannelId = s.path("epg_channel_id").asText("");
            String tvgId = epgChannelId.isBlank() ? streamId : epgChannelId;
            String url = base + "/live/" + u + "/" + p + "/" + streamId + ".m3u8";
            int num = s.has("num") && !s.get("num").isNull() ? s.get("num").asInt(i) : i;
            channels.add(new ParsedChannel(name, logo, group, tvgId, url, num));
        }

        String epgRaw = null;
        try {
            String candidate = http.fetchText(base + "/xmltv.php?username=" + u + "&password=" + p);
            if (candidate != null && candidate.toLowerCase().contains("<tv")) epgRaw = candidate;
        } catch (Exception ignored) {
            // EPG is optional — the panel may not expose xmltv.php
        }

        return new XtreamResult(channels, epgRaw);
    }
}
