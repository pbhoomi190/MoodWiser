import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_analysis.dart';
import 'package:mood_wiser/features/mood_tracking/domain/repositories/mood_entry_repository.dart';
import 'package:mood_wiser/features/mood_tracking/domain/services/mood_analyzer.dart';

// Use case for analyzing mood entries over a specified period.
final class AnalyzeMoodEntries {
  const AnalyzeMoodEntries(this._repository, this._analyzer);

  final MoodEntryRepository _repository;
  final MoodAnalyzer _analyzer;

  Future<MoodAnalysis> call({
    required MoodAnalysisPeriod period,
    DateTime? now,
  }) async {
    final entries = await _repository.getAll();
    return _analyzer.analyze(entries: entries, period: period, now: now);
  }
}
