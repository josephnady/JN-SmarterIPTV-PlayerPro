# JN Smarter IPTV Player Pro — Backend

A local, single-user Spring Boot REST API that does the same job the Electron app's
`main.js` currently does — fetching/parsing M3U playlists, logging into Xtream Codes panels,
and parsing XMLTV guides — but as a standalone server with real persistence (H2, file-based)
instead of a JSON blob. No login/accounts — this is a local backend for one desktop install.

## 1. Prerequisites

- JDK 17+
- Maven 3.8+ (or use your IDE's built-in Maven support)

## 2. Run it

```bash
cd backend
mvn spring-boot:run
```

First run needs internet access to pull dependencies (like `npm install` for the desktop
app). The API starts on **http://localhost:8787**. Data is stored in `backend/data/iptvdb.mv.db`
(an H2 file database) — delete that file to reset everything.

Check it's alive:

```bash
curl http://localhost:8787/api/health
```

## 3. API reference

All routes are prefixed `/api`. Responses are JSON; errors come back as `{"error": "..."}`.

### Playlists

| Method | Route                          | Body / Params                              | Notes |
|--------|---------------------------------|---------------------------------------------|-------|
| GET    | `/playlists`                    | —                                            | List all playlists with channel counts |
| POST   | `/playlists/m3u`                | `{ name, url, epgUrl? }`                     | Fetches & parses an M3U/M3U8 URL server-side |
| POST   | `/playlists/m3u/upload`         | multipart: `name`, `file`, `epgFile?`        | Upload a local `.m3u`/`.xml` pair |
| POST   | `/playlists/xtream`             | `{ name, host, username, password }`         | Logs in via `player_api.php`, pulls live channels + EPG |
| POST   | `/playlists/{id}/refresh`       | —                                             | Re-fetches from the original source (not available for uploaded files) |
| DELETE | `/playlists/{id}`               | —                                             | Removes the playlist and its channels |
| GET    | `/playlists/{id}/channels`      | `?search=&group=&favoritesOnly=` | Filtered channel list |
| GET    | `/playlists/{id}/groups`        | —                                             | Distinct group/category names |

### Channels & favorites

| Method | Route                          | Notes |
|--------|----------------------------------|-------|
| GET    | `/favorites`                     | All favorited channels, across playlists |
| POST   | `/channels/{id}/favorite`        | Toggles favorite, returns the updated channel |
| GET    | `/channels/{id}/epg`             | `{ nowTitle, nextTitle, programmes: [...] }` from the playlist's cached XMLTV |

### Settings

| Method | Route        | Body |
|--------|--------------|------|
| GET    | `/settings`  | — |
| PUT    | `/settings`  | `{ autoplayLast?, lastChannelId? }` — partial updates, omit fields you don't want to change |

### Example

```bash
curl -X POST http://localhost:8787/api/playlists/xtream \
  -H "Content-Type: application/json" \
  -d '{"name":"My provider","host":"http://host:port","username":"user","password":"pass"}'
```

## 4. How this relates to the desktop app

Right now the Electron app (`main.js` / `renderer.js`) still does all of this itself via IPC —
this backend isn't wired into it yet. To make the desktop app use this API instead:

- swap the `window.signal.*` calls in `src/renderer.js` for `fetch("http://localhost:8787/api/...")`
- start this Spring Boot app alongside Electron (e.g. `child_process.spawn` the built jar from
  `main.js`, or just run it separately during development)

Say the word and I can wire that integration up directly.

## 5. Notes & caveats

- **No auth** — this is meant to run on `localhost` for a single local user. Don't expose port
  8787 to the network as-is.
- **Xtream password storage** — currently stored in plain text in the H2 database for
  simplicity. Encrypt the `xtream_password` column (e.g. with Jasypt) before using this beyond
  a local dev setup.
- **EPG caching** — parsed XMLTV is cached in memory per playlist and rebuilt on first request
  after startup or after `/refresh`; it isn't persisted separately from the raw XML.
- **Stream playback** — channel URLs are returned as-is (no proxying), so playback CORS/redirect
  behavior depends on the provider, same as the current desktop app.

## Project structure

```
backend/
├── pom.xml
└── src/main/
    ├── resources/application.yml
    └── java/com/jnsmarter/iptvbackend/
        ├── IptvBackendApplication.java
        ├── config/CorsConfig.java
        ├── model/            # Playlist, Channel, AppSettings JPA entities
        ├── repository/       # Spring Data JPA repositories
        ├── parsing/          # M3U + XMLTV parsers (pure Java, no framework deps)
        ├── client/           # HTTP fetch + Xtream Codes API client
        ├── service/          # Business logic
        ├── controller/       # REST endpoints
        └── exception/        # Error handling
```
