import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';

/// Represents the configuration for mood tracking, including available feelings and triggers.
/// The configuration is loaded from a JSON file and parsed into a `MoodConfig` instance.
final class MoodConfig {
  const MoodConfig({required this.feelings, required this.triggers});

  final List<MoodOption> feelings;
  final List<MoodOption> triggers;

  static Future<MoodConfig> load() async {
    final String json = await rootBundle.loadString(
      AppStrings.moodConfigAssetPath,
    );
    final Map<String, dynamic> data = jsonDecode(json) as Map<String, dynamic>;

    return MoodConfig(
      feelings: _parseOptions(data['feelings']),
      triggers: _parseOptions(data['triggers']),
    );
  }

  static List<MoodOption> _parseOptions(dynamic value) {
    return (value as List<dynamic>)
        .map(
          (dynamic option) =>
              MoodOption.fromJson(option as Map<String, dynamic>),
        )
        .toList(growable: false);
  }
}

final class MoodOption {
  const MoodOption({required this.name, required this.color});

  final String name;
  final Color color;

  factory MoodOption.fromJson(Map<String, dynamic> json) {
    final String hexColor = json['color'] as String;
    return MoodOption(
      name: json['name'] as String,
      color: Color(0xFF000000 | int.parse(hexColor.substring(1), radix: 16)),
    );
  }
}
