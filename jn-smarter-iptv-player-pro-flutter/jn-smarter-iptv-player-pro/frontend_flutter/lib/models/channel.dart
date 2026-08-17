class Channel {
  final int id;
  final String name;
  final String logoUrl;
  final String groupTitle;
  final String tvgId;
  final String streamUrl;
  final int channelNumber;
  final bool favorite;
  final int playlistId;

  Channel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.groupTitle,
    required this.tvgId,
    required this.streamUrl,
    required this.channelNumber,
    required this.favorite,
    required this.playlistId,
  });

  factory Channel.fromJson(Map<String, dynamic> json) => Channel(
        id: json['id'] as int,
        name: json['name'] as String? ?? 'Unnamed channel',
        logoUrl: json['logoUrl'] as String? ?? '',
        groupTitle: json['groupTitle'] as String? ?? 'Uncategorized',
        tvgId: json['tvgId'] as String? ?? '',
        streamUrl: json['streamUrl'] as String,
        channelNumber: json['channelNumber'] as int? ?? 0,
        favorite: json['favorite'] as bool? ?? false,
        playlistId: json['playlistId'] as int,
      );
}
