import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/domain/repositories/mood_entry_repository.dart';

final class SaveMoodEntry {
  const SaveMoodEntry(this._repository);

  final MoodEntryRepository _repository;

  Future<void> call({
    required int score,
    required String feeling,
    required String trigger,
    String? note,
    required DateTime date,
  }) {
    return _repository.save(
      MoodEntry(
        score: score,
        feeling: feeling,
        trigger: trigger,
        note: note,
        date: date,
      ),
    );
  }
}
