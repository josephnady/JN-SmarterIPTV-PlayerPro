class AppSettingsModel {
  final bool autoplayLast;
  final int? lastChannelId;

  AppSettingsModel({required this.autoplayLast, required this.lastChannelId});

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) => AppSettingsModel(
        autoplayLast: json['autoplayLast'] as bool? ?? true,
        lastChannelId: json['lastChannelId'] as int?,
      );
}
