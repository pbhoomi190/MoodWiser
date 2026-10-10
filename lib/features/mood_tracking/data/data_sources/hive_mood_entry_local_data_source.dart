import 'package:mood_wiser/core/database/entities/mood_entry.dart' as hive;
import 'package:mood_wiser/core/database/hive_service.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart'
    as domain;

final class HiveMoodEntryLocalDataSource {
  Future<void> save(domain.MoodEntry entry) async {
    final hiveEntry = hive.MoodEntry(
      id: entry.id ?? 0,
      score: entry.score,
      feeling: entry.feeling,
      trigger: entry.trigger,
      note: entry.note,
      date: entry.date,
    );
    if (entry.id == null) {
      await HiveService.addMoodEntry(hiveEntry);
      return;
    }
    await HiveService.updateMoodEntry(entry.id!, hiveEntry);
  }

  Future<void> delete(int id) {
    return HiveService.deleteMoodEntry(id);
  }
}
