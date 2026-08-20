import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/channel.dart';
import '../models/epg.dart';
import '../models/playlist.dart';
import 'api_client.dart';

enum ChannelTab { all, favorites }

class AppState extends ChangeNotifier {
  static const _prefsBaseUrlKey = 'api_base_url';
  static const defaultBaseUrl = 'http://localhost:8787';

  late ApiClient api;
  String baseUrl = defaultBaseUrl;
  bool backendReachable = true;

  List<Playlist> playlists = [];
  int? activePlaylistId;
  List<Channel> channels = [];
  List<String> groups = [];
  String? groupFilter;
  String searchQuery = '';
  ChannelTab tab = ChannelTab.all;
  bool autoplayLast = true;

  // Playback itself (video controller, loading/error state) is owned by the
  // platform-specific ChannelPlayer widget — AppState only tracks *which*
  // channel is tuned in, for the sidebar/tuner-dial/EPG UI.
  Channel? activeChannel;
  EpgResponse epg = EpgResponse.empty();

  bool loadingPlaylists = false;
  bool loadingChannels = false;
  String? lastError;

  AppState() {
    api = ApiClient(baseUrl: baseUrl);
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    baseUrl = prefs.getString(_prefsBaseUrlKey) ?? defaultBaseUrl;
    api = ApiClient(baseUrl: baseUrl);
    backendReachable = await api.health();
    notifyListeners();
    if (!backendReachable) return;

    try {
      final settings = await api.getSettings();
      autoplayLast = settings.autoplayLast;
    } catch (_) {
      // keep local defaults if settings can't be read yet
    }

    await loadPlaylists();
  }

  Future<void> setBaseUrl(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsBaseUrlKey, trimmed);
    baseUrl = trimmed;
    api = ApiClient(baseUrl: trimmed);
    backendReachable = await api.health();
    notifyListeners();
    if (backendReachable) await loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    loadingPlaylists = true;
    lastError = null;
    notifyListeners();
    try {
      playlists = await api.listPlaylists();
      if ((activePlaylistId == null || !playlists.any((p) => p.id == activePlaylistId)) &&
          playlists.isNotEmpty) {
        activePlaylistId = playlists.first.id;
      }
      if (activePlaylistId != null) {
        await _loadChannelsAndGroups();
      } else {
        channels = [];
        groups = [];
      }
    } catch (e) {
      lastError = e.toString();
    } finally {
      loadingPlaylists = false;
      notifyListeners();
    }
  }

  Future<void> selectPlaylist(int id) async {
    activePlaylistId = id;
    groupFilter = null;
    searchQuery = '';
    tab = ChannelTab.all;
    notifyListeners();
    await _loadChannelsAndGroups();
  }

  Future<void> _loadChannelsAndGroups() async {
    if (activePlaylistId == null) return;
    loadingChannels = true;
    notifyListeners();
    try {
      final id = activePlaylistId!;
      groups = await api.listGroups(id);
      await refreshChannelList();
    } catch (e) {
      lastError = e.toString();
    } finally {
      loadingChannels = false;
      notifyListeners();
    }
  }

  Future<void> refreshChannelList() async {
    if (activePlaylistId == null) return;
    try {
      channels = await api.listChannels(
        activePlaylistId!,
        search: searchQuery,
        group: groupFilter,
        favoritesOnly: tab == ChannelTab.favorites,
      );
      notifyListeners();
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  void setSearch(String value) {
    searchQuery = value;
    refreshChannelList();
  }

  void setGroupFilter(String? group) {
    groupFilter = group;
    refreshChannelList();
  }

  void setTab(ChannelTab value) {
    tab = value;
    refreshChannelList();
  }

  Future<void> addM3uUrl({required String name, required String url, String? epgUrl}) async {
    final playlist = await api.addM3uUrl(name: name, url: url, epgUrl: epgUrl);
    await loadPlaylists();
    await selectPlaylist(playlist.id);
  }

  Future<void> addXtream({
    required String name,
    required String host,
    required String username,
    required String password,
  }) async {
    final playlist = await api.addXtream(name: name, host: host, username: username, password: password);
    await loadPlaylists();
    await selectPlaylist(playlist.id);
  }

  Future<void> addM3uUpload({
    required String name,
    required List<int> m3uBytes,
    required String m3uFilename,
    List<int>? epgBytes,
    String? epgFilename,
  }) async {
    final playlist = await api.addM3uUpload(
      name: name,
      m3uBytes: m3uBytes,
      m3uFilename: m3uFilename,
      epgBytes: epgBytes,
      epgFilename: epgFilename,
    );
    await loadPlaylists();
    await selectPlaylist(playlist.id);
  }

  Future<void> refreshPlaylistById(int id) async {
    try {
      await api.refreshPlaylist(id);
      await loadPlaylists();
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePlaylist(int id) async {
    await api.deletePlaylist(id);
    if (activePlaylistId == id) {
      activePlaylistId = null;
      channels = [];
      activeChannel = null;
    }
    await loadPlaylists();
  }

  Future<void> toggleFavorite(Channel channel) async {
    final updated = await api.toggleFavorite(channel.id);
    channels = channels.map((c) => c.id == updated.id ? updated : c).toList();
    if (activeChannel?.id == updated.id) activeChannel = updated;
    notifyListeners();
  }

  Future<void> setAutoplayLast(bool value) async {
    autoplayLast = value;
    notifyListeners();
    try {
      await api.updateSettings(autoplayLast: value);
    } catch (_) {
      // non-critical
    }
  }

  /// Marks a channel as tuned in and fetches its EPG. Actual video playback
  /// is handled by the ChannelPlayer widget watching `activeChannel`.
  Future<void> playChannel(Channel channel) async {
    activeChannel = channel;
    epg = EpgResponse.empty();
    notifyListeners();

    try {
      epg = await api.getEpg(channel.id);
      notifyListeners();
    } catch (_) {
      // EPG is best-effort
    }

    try {
      await api.updateSettings(lastChannelId: channel.id);
    } catch (_) {
      // non-critical
    }
  }

  Future<void> refreshEpgForActiveChannel() async {
    if (activeChannel == null) return;
    try {
      epg = await api.getEpg(activeChannel!.id);
      notifyListeners();
    } catch (_) {
      // ignore transient EPG refresh failures
    }
  }
}
