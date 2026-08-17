package com.jnsmarter.iptvbackend.parsing;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public final class M3uParser {

    private static final Pattern ATTR_PATTERN = Pattern.compile("([a-zA-Z0-9\\-]+)=\"([^\"]*)\"");

    private M3uParser() {
    }

    public static List<ParsedChannel> parse(String text) {
        List<ParsedChannel> channels = new ArrayList<>();
        if (text == null || text.isBlank()) return channels;

        String[] lines = text.split("\r?\n");
        Map<String, String> pendingAttrs = null;
        String pendingName = null;
        int idx = 0;

        for (String raw : lines) {
            String line = raw.trim();
            if (line.isEmpty()) continue;

            if (line.startsWith("#EXTINF")) {
                Map<String, String> attrs = new LinkedHashMap<>();
                Matcher m = ATTR_PATTERN.matcher(line);
                while (m.find()) {
                    attrs.put(m.group(1).toLowerCase(), m.group(2));
                }
                int commaIdx = line.lastIndexOf(',');
                String name = commaIdx >= 0 ? line.substring(commaIdx + 1).trim() : "Unnamed channel";
                pendingAttrs = attrs;
                pendingName = name.isBlank() ? "Unnamed channel" : name;
            } else if (line.startsWith("#")) {
                // skip other directives (#EXTM3U, #EXTGRP, #EXTVLCOPT, ...)
            } else {
                idx++;
                if (pendingAttrs != null) {
                    channels.add(new ParsedChannel(
                            pendingName,
                            pendingAttrs.getOrDefault("tvg-logo", ""),
                            emptyToDefault(pendingAttrs.get("group-title"), "Uncategorized"),
                            firstNonBlank(pendingAttrs.get("tvg-id"), pendingAttrs.get("tvg-name")),
                            line,
                            idx
                    ));
                    pendingAttrs = null;
                    pendingName = null;
                } else {
                    String fallbackName = line.contains("/") ? line.substring(line.lastIndexOf('/') + 1) : line;
                    channels.add(new ParsedChannel(fallbackName, "", "Uncategorized", "", line, idx));
                }
            }
        }
        return channels;
    }

    private static String emptyToDefault(String value, String fallback) {
        return (value == null || value.isBlank()) ? fallback : value;
    }

    private static String firstNonBlank(String a, String b) {
        if (a != null && !a.isBlank()) return a;
        if (b != null && !b.isBlank()) return b;
        return "";
    }
}
