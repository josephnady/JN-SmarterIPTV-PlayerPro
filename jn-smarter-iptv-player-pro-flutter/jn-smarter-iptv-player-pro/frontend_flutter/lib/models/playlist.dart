class Playlist {
  final int id;
  final String name;
  final String type; // M3U_URL | M3U_FILE | XTREAM
  final int channelCount;
  final DateTime addedAt;
  final bool refreshable;

  Playlist({
    required this.id,
    required this.name,
    required this.type,
    required this.channelCount,
    required this.addedAt,
    required this.refreshable,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        channelCount: json['channelCount'] as int,
        addedAt: DateTime.parse(json['addedAt'] as String),
        refreshable: json['refreshable'] as bool,
      );
}
