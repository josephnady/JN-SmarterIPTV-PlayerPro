class EpgProgramme {
  final String title;
  final String description;
  final int start;
  final int? stop;
  final bool current;

  EpgProgramme({
    required this.title,
    required this.description,
    required this.start,
    required this.stop,
    required this.current,
  });

  DateTime get startTime => DateTime.fromMillisecondsSinceEpoch(start);

  factory EpgProgramme.fromJson(Map<String, dynamic> json) => EpgProgramme(
        title: json['title'] as String? ?? 'Untitled',
        description: json['description'] as String? ?? '',
        start: json['start'] as int,
        stop: json['stop'] as int?,
        current: json['current'] as bool? ?? false,
      );
}

class EpgResponse {
  final String? nowTitle;
  final String? nextTitle;
  final List<EpgProgramme> programmes;

  EpgResponse({required this.nowTitle, required this.nextTitle, required this.programmes});

  factory EpgResponse.fromJson(Map<String, dynamic> json) => EpgResponse(
        nowTitle: json['nowTitle'] as String?,
        nextTitle: json['nextTitle'] as String?,
        programmes: (json['programmes'] as List<dynamic>? ?? [])
            .map((e) => EpgProgramme.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  static EpgResponse empty() => EpgResponse(nowTitle: null, nextTitle: null, programmes: []);
}
