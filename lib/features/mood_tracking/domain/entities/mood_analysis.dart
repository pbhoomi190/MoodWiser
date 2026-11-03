import 'dart:convert';

import 'package:mood_wiser/core/utilities/mood_analysis_constants.dart';

enum MoodAnalysisPeriod {
  weekly(7),
  monthly(30),
  yearly(365);

  const MoodAnalysisPeriod(this.days);

  final int days;

  String get payloadName => name;
}

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

final class MoodOutlierSample {
  const MoodOutlierSample({
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

final class MoodAnalysis {
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
    required this.outlierSamples,
  });

  final MoodAnalysisPeriod period;
  final int totalEntries;
  final double? averageMood;
  final double? standardDeviation;
  final double? slopePerDay;
  final List<MoodTriggerImpact> positiveTriggers;
  final List<MoodTriggerImpact> negativeTriggers;
  final List<String> topFeelings;
  final List<MoodOutlierSample> outlierSamples;

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
    MoodAnalysisPayloadKeys.outlierSamples: outlierSamples
        .map((MoodOutlierSample sample) => sample.toJson())
        .toList(growable: false),
  };

  String toJson() => jsonEncode(toMap());
}

String _dateLabel(DateTime date) {
  final String month = date.month.toString().padLeft(2, '0');
  final String day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
