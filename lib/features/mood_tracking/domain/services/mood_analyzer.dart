import 'dart:math' as math;

import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_analysis.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';

final class MoodAnalyzer {
  static const double _positiveImpactThreshold = 1;
  static const double _negativeImpactThreshold = -1;
  static const int _outlierCount = 3;

  MoodAnalysis analyze({
    required List<MoodEntry> entries,
    required MoodAnalysisPeriod period,
    DateTime? now,
  }) {
    final DateTime today = now ?? DateTime.now();
    final DateTime endExclusive = DateTime(
      today.year,
      today.month,
      today.day + 1,
    );
    final DateTime startInclusive = DateTime(
      today.year,
      today.month,
      today.day - period.days + 1,
    );
    final List<MoodEntry> selectedEntries = entries
        .where(
          (MoodEntry entry) =>
              !entry.date.isBefore(startInclusive) &&
              entry.date.isBefore(endExclusive),
        )
        .toList(growable: false);

    if (selectedEntries.isEmpty) {
      return MoodAnalysis(
        period: period,
        totalEntries: 0,
        averageMood: null,
        standardDeviation: null,
        slopePerDay: null,
        positiveTriggers: const <MoodTriggerImpact>[],
        negativeTriggers: const <MoodTriggerImpact>[],
        topFeelings: const <String>[],
        outlierSamples: const <MoodOutlierSample>[],
      );
    }

    final double average =
        selectedEntries
            .map((MoodEntry entry) => entry.score)
            .reduce((int total, int score) => total + score) /
        selectedEntries.length;
    final double variance =
        selectedEntries
            .map((MoodEntry entry) => math.pow(entry.score - average, 2))
            .reduce((num total, num value) => total + value) /
        selectedEntries.length;
    final Map<String, _TriggerStats> triggers = <String, _TriggerStats>{};
    final Map<String, _FeelingStats> feelings = <String, _FeelingStats>{};

    for (final MoodEntry entry in selectedEntries) {
      for (final String trigger in _splitOptions(entry.trigger)) {
        final String key = trigger.toLowerCase();
        final _TriggerStats stats = triggers.putIfAbsent(
          key,
          () => _TriggerStats(trigger),
        );
        stats.frequency++;
        stats.moodTotal += entry.score;
      }
      for (final String feeling in _splitOptions(entry.feeling)) {
        final String key = feeling.toLowerCase();
        final _FeelingStats stats = feelings.putIfAbsent(
          key,
          () => _FeelingStats(feeling),
        );
        stats.frequency++;
      }
    }

    final List<MoodTriggerImpact> impacts = triggers.values
        .map(
          (_TriggerStats stats) => MoodTriggerImpact(
            trigger: stats.label,
            frequency: stats.frequency,
            delta: stats.moodTotal / stats.frequency - average,
          ),
        )
        .toList(growable: false);
    final List<MoodTriggerImpact> positiveTriggers =
        impacts
            .where(
              (MoodTriggerImpact impact) =>
                  impact.delta > _positiveImpactThreshold,
            )
            .toList()
          ..sort(
            (MoodTriggerImpact left, MoodTriggerImpact right) =>
                right.delta.compareTo(left.delta),
          );
    final List<MoodTriggerImpact> negativeTriggers =
        impacts
            .where(
              (MoodTriggerImpact impact) =>
                  impact.delta < _negativeImpactThreshold,
            )
            .toList()
          ..sort(
            (MoodTriggerImpact left, MoodTriggerImpact right) =>
                left.delta.compareTo(right.delta),
          );

    final List<_FeelingStats> topFeelings = feelings.values.toList()
      ..sort((_FeelingStats left, _FeelingStats right) {
        final int byFrequency = right.frequency.compareTo(left.frequency);
        return byFrequency != 0
            ? byFrequency
            : left.label.compareTo(right.label);
      });

    return MoodAnalysis(
      period: period,
      totalEntries: selectedEntries.length,
      averageMood: average,
      standardDeviation: math.sqrt(variance),
      slopePerDay: _slopePerDay(selectedEntries),
      positiveTriggers: positiveTriggers,
      negativeTriggers: negativeTriggers,
      topFeelings: topFeelings
          .take(3)
          .map(
            (_FeelingStats feeling) =>
                '${feeling.label} (${feeling.frequency}x)',
          )
          .toList(growable: false),
      outlierSamples: _outlierSamples(selectedEntries),
    );
  }

  double? _slopePerDay(List<MoodEntry> entries) {
    if (entries.length < 2) {
      return null;
    }
    final DateTime origin = entries
        .map((MoodEntry entry) => entry.date)
        .reduce((DateTime a, DateTime b) => a.isBefore(b) ? a : b);
    final List<double> days = entries
        .map(
          (MoodEntry entry) =>
              entry.date.difference(origin).inMicroseconds /
              Duration.microsecondsPerDay,
        )
        .toList(growable: false);
    final double meanDays =
        days.reduce((double a, double b) => a + b) / days.length;
    final double meanScores =
        entries
            .map((MoodEntry entry) => entry.score)
            .reduce((int a, int b) => a + b) /
        entries.length;
    double numerator = 0;
    double denominator = 0;
    for (int index = 0; index < entries.length; index++) {
      final double dayOffset = days[index] - meanDays;
      numerator += dayOffset * (entries[index].score - meanScores);
      denominator += dayOffset * dayOffset;
    }
    if (denominator == 0) {
      return null;
    }
    return numerator / denominator;
  }

  List<MoodOutlierSample> _outlierSamples(List<MoodEntry> entries) {
    final List<MoodEntry> lowest = entries.toList()
      ..sort((MoodEntry a, MoodEntry b) {
        final int byScore = a.score.compareTo(b.score);
        return byScore != 0 ? byScore : a.date.compareTo(b.date);
      });
    final List<MoodEntry> highest = entries.toList()
      ..sort((MoodEntry a, MoodEntry b) {
        final int byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : b.date.compareTo(a.date);
      });
    final Set<MoodEntry> selected = <MoodEntry>{...lowest.take(_outlierCount)};
    selected.addAll(highest.take(_outlierCount));
    return selected
        .map(
          (MoodEntry entry) => MoodOutlierSample(
            date: entry.date,
            mood: entry.score,
            feelings: entry.feeling,
            trigger: entry.trigger,
            note: entry.note,
          ),
        )
        .toList(growable: false);
  }

  List<String> _splitOptions(String value) {
    final List<String> options = <String>[];
    final Set<String> seen = <String>{};
    for (final String rawOption in value.split(',')) {
      final String option = rawOption.trim();
      if (option.isNotEmpty && seen.add(option.toLowerCase())) {
        options.add(option);
      }
    }
    return options;
  }
}

final class _TriggerStats {
  _TriggerStats(this.label);

  final String label;
  int frequency = 0;
  int moodTotal = 0;
}

final class _FeelingStats {
  _FeelingStats(this.label);

  final String label;
  int frequency = 0;
}
