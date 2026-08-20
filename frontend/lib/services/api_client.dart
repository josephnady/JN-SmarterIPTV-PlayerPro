import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/app_settings.dart';
import '../models/channel.dart';
import '../models/epg.dart';
import '../models/playlist.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  final String baseUrl;
  ApiClient({required this.baseUrl});

  Uri _u(String path, [Map<String, String>? query]) =>
      Uri.parse('$baseUrl$path').replace(queryParameters: query);

  Map<String, String> get _jsonHeaders => {'Content-Type': 'application/json'};

  Future<T> _handle<T>(http.Response res, T Function(dynamic json) onOk) async {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      final body = res.body.isEmpty ? null : jsonDecode(res.body);
      return onOk(body);
    }
    String message = 'Request failed (${res.statusCode})';
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['error'] != null) message = body['error'].toString();
    } catch (_) {
      // keep the generic message if the error body isn't JSON
    }
    throw ApiException(message);
  }

  Future<bool> health() async {
    try {
      final res = await http.get(_u('/api/health')).timeout(const Duration(seconds: 5));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Playlist>> listPlaylists() async {
    final res = await http.get(_u('/api/playlists'));
    return _handle(
        res,
        (json) =>
            (json as List<dynamic>).map((e) => Playlist.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<Playlist> addM3uUrl({required String name, required String url, String? epgUrl}) async {
    final res = await http.post(
      _u('/api/playlists/m3u'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'name': name,
        'url': url,
        if (epgUrl != null && epgUrl.isNotEmpty) 'epgUrl': epgUrl,
      }),
    );
    return _handle(res, (json) => Playlist.fromJson(json as Map<String, dynamic>));
  }

  Future<Playlist> addXtream({
    required String name,
    required String host,
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      _u('/api/playlists/xtream'),
      headers: _jsonHeaders,
      body: jsonEncode({'name': name, 'host': host, 'username': username, 'password': password}),
    );
    return _handle(res, (json) => Playlist.fromJson(json as Map<String, dynamic>));
  }

  Future<Playlist> addM3uUpload({
    required String name,
    required List<int> m3uBytes,
    required String m3uFilename,
    List<int>? epgBytes,
    String? epgFilename,
  }) async {
    final request = http.MultipartRequest('POST', _u('/api/playlists/m3u/upload'));
    request.fields['name'] = name;
    request.files.add(http.MultipartFile.fromBytes('file', m3uBytes, filename: m3uFilename));
    if (epgBytes != null && epgFilename != null) {
      request.files.add(http.MultipartFile.fromBytes('epgFile', epgBytes, filename: epgFilename));
    }
    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    return _handle(res, (json) => Playlist.fromJson(json as Map<String, dynamic>));
  }

  Future<Playlist> refreshPlaylist(int id) async {
    final res = await http.post(_u('/api/playlists/$id/refresh'));
    return _handle(res, (json) => Playlist.fromJson(json as Map<String, dynamic>));
  }

  Future<void> deletePlaylist(int id) async {
    final res = await http.delete(_u('/api/playlists/$id'));
    await _handle(res, (_) => null);
  }

  Future<List<Channel>> listChannels(int playlistId, {String? search, String? group, bool favoritesOnly = false}) async {
    final query = <String, String>{'favoritesOnly': favoritesOnly.toString()};
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (group != null && group.isNotEmpty) query['group'] = group;
    final res = await http.get(_u('/api/playlists/$playlistId/channels', query));
    return _handle(
        res,
        (json) =>
            (json as List<dynamic>).map((e) => Channel.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<List<String>> listGroups(int playlistId) async {
    final res = await http.get(_u('/api/playlists/$playlistId/groups'));
    return _handle(res, (json) => (json as List<dynamic>).map((e) => e.toString()).toList());
  }

  Future<List<Channel>> listFavorites() async {
    final res = await http.get(_u('/api/favorites'));
    return _handle(
        res,
        (json) =>
            (json as List<dynamic>).map((e) => Channel.fromJson(e as Map<String, dynamic>)).toList());
  }

  Future<Channel> toggleFavorite(int channelId) async {
    final res = await http.post(_u('/api/channels/$channelId/favorite'));
    return _handle(res, (json) => Channel.fromJson(json as Map<String, dynamic>));
  }

  Future<EpgResponse> getEpg(int channelId) async {
    final res = await http.get(_u('/api/channels/$channelId/epg'));
    return _handle(res, (json) => EpgResponse.fromJson(json as Map<String, dynamic>));
  }

  Future<AppSettingsModel> getSettings() async {
    final res = await http.get(_u('/api/settings'));
    return _handle(res, (json) => AppSettingsModel.fromJson(json as Map<String, dynamic>));
  }

  Future<AppSettingsModel> updateSettings({bool? autoplayLast, int? lastChannelId}) async {
    final body = <String, dynamic>{};
    if (autoplayLast != null) body['autoplayLast'] = autoplayLast;
    if (lastChannelId != null) body['lastChannelId'] = lastChannelId;
    final res = await http.put(_u('/api/settings'), headers: _jsonHeaders, body: jsonEncode(body));
    return _handle(res, (json) => AppSettingsModel.fromJson(json as Map<String, dynamic>));
  }
}
