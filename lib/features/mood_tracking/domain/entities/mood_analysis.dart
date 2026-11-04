import 'dart:convert';

import 'package:mood_wiser/core/utilities/mood_analysis_constants.dart';

enum MoodAnalysisPeriod {
  weekly(7),
  monthly(30),
  yearly(365);

  const MoodAnalysisPeriod(this.days);

  final int days;

  // this will return the name of the enum value as a string, e.g., 'weekly', 'monthly', or 'yearly'.
  String get payloadName => name;
}

// This class represents the impact of a specific trigger on mood,
// including its frequency and the change in mood associated with it.
final class MoodTriggerImpact {
  const MoodTriggerImpact({
    required this.trigger,
    required this.frequency,
    required this.delta,
  });

  final String trigger;
  final int frequency;
  final double delta;

  Map<String, Object> toJson() => <String, Object>{
    MoodAnalysisPayloadKeys.trigger: trigger,
    MoodAnalysisPayloadKeys.frequency: frequency,
    MoodAnalysisPayloadKeys.delta: deltaLabel,
  };

  String get deltaLabel =>
      '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)}';
}

// A selected high or low scoring entry shown in mood analysis.
final class MoodEntryHighlight {
  const MoodEntryHighlight({
    required this.date,
    required this.mood,
    required this.feelings,
    required this.trigger,
    required this.note,
  });

  final DateTime date;
  final int mood;
  final String feelings;
  final String trigger;
  final String? note;

  Map<String, Object?> toJson() => <String, Object?>{
    MoodAnalysisPayloadKeys.date: _dateLabel(date),
    MoodAnalysisPayloadKeys.mood: mood,
    MoodAnalysisPayloadKeys.feelings: feelings,
    MoodAnalysisPayloadKeys.trigger: trigger,
    MoodAnalysisPayloadKeys.note: note,
  };
}

/// This class encapsulates the results of a mood analysis over a specified period.

/// period - The timeframe over which the mood analysis was conducted (e.g., weekly, monthly, yearly).
/// totalEntries - The total number of mood entries analyzed during the specified period.
/// averageMood - The average mood score calculated from the analyzed entries, which may be null if insufficient data is available.
/// standardDeviation - The standard deviation of mood scores, indicating the variability of mood during the analysis period
/// slopePerDay - The calculated slope of mood scores over time, representing the trend in mood changes per day.
/// positiveTriggers - A list of triggers that have a positive impact on mood, each represented by a MoodTriggerImpact object.
/// negativeTriggers - A list of triggers that have a negative impact on mood, each represented by a MoodTriggerImpact object.
/// topFeelings - A list of the most frequently reported feelings during the analysis period.
/// entryHighlights - Selected high- and low-scoring mood entries.
final class MoodAnalysis {
  // used to determine if the slope is considered flat, indicating no significant trend in mood over time.
  static const double _flatTrendThreshold = 0.01;

  const MoodAnalysis({
    required this.period,
    required this.totalEntries,
    required this.averageMood,
    required this.standardDeviation,
    required this.slopePerDay,
    required this.positiveTriggers,
    required this.negativeTriggers,
    required this.topFeelings,
    required this.entryHighlights,
  });

  final MoodAnalysisPeriod period;
  final int totalEntries;
  final double? averageMood;
  final double? standardDeviation;
  final double? slopePerDay;
  final List<MoodTriggerImpact> positiveTriggers;
  final List<MoodTriggerImpact> negativeTriggers;
  final List<String> topFeelings;
  final List<MoodEntryHighlight> entryHighlights;

  /// For example, `slopePerDay: 0.15` returns `upward (+0.15/day)`.
  String get trend {
    final double? slope = slopePerDay;
    if (slope == null) {
      return MoodAnalysisPayloadLabels.insufficientData;
    }
    final String direction = slope > _flatTrendThreshold
        ? MoodAnalysisPayloadLabels.upward
        : slope < -_flatTrendThreshold
        ? MoodAnalysisPayloadLabels.downward
        : MoodAnalysisPayloadLabels.flat;
    return '$direction (${slope >= 0 ? '+' : ''}'
        '${slope.toStringAsFixed(2)}/day)';
  }

  /// For example, `standardDeviation: 1.4` returns `moderate (std_dev: 1.4)`.
  String get volatility {
    final double? deviation = standardDeviation;
    if (deviation == null) {
      return MoodAnalysisPayloadLabels.insufficientData;
    }
    final String level = deviation >= 2
        ? MoodAnalysisPayloadLabels.high
        : deviation >= 1
        ? MoodAnalysisPayloadLabels.moderate
        : MoodAnalysisPayloadLabels.low;
    return '$level (std_dev: ${deviation.toStringAsFixed(1)})';
  }

  /// Converts the MoodAnalysis object into a Map representation, suitable for serialization or further processing.
  /// Later will use it to pass it to the local model or api for generating insights.
  Map<String, Object?> toMap() => <String, Object?>{
    MoodAnalysisPayloadKeys.timeframe: period.payloadName,
    MoodAnalysisPayloadKeys.totalEntries: totalEntries,
    MoodAnalysisPayloadKeys.metrics: <String, Object?>{
      MoodAnalysisPayloadKeys.averageMood: averageMood == null
          ? null
          : double.parse(averageMood!.toStringAsFixed(1)),
      MoodAnalysisPayloadKeys.trend: trend,
      MoodAnalysisPayloadKeys.volatility: volatility,
    },
    MoodAnalysisPayloadKeys.correlations: <String, Object>{
      MoodAnalysisPayloadKeys.positiveTriggers: positiveTriggers
          .map((MoodTriggerImpact impact) => impact.toJson())
          .toList(growable: false),
      MoodAnalysisPayloadKeys.negativeTriggers: negativeTriggers
          .map((MoodTriggerImpact impact) => impact.toJson())
          .toList(growable: false),
    },
    MoodAnalysisPayloadKeys.topFeelings: topFeelings,
    MoodAnalysisPayloadKeys.entryHighlights: entryHighlights
        .map((MoodEntryHighlight sample) => sample.toJson())
        .toList(growable: false),
  };

  String toJson() => jsonEncode(toMap());
}

String _dateLabel(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
