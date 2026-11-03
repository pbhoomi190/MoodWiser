import 'package:mood_wiser/core/database/entities/mood_entry.dart' as hive;
import 'package:mood_wiser/core/database/hive_service.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart'
    as domain;

final class HiveMoodEntryLocalDataSource {
  // Retrieves all mood entries from the local 
  // Hive database and converts them to domain entities.

  // Hive and domain entities are different representations of the same data,
  // so we need to map between them when saving or retrieving data.

  // Growable is set to false to prevent accidental modifications to the list of entries.
  // If acciedentally someone tries to add or remove entries from the list,
  // it will throw an error, which helps catch bugs early.
  Future<List<domain.MoodEntry>> getAll() async {
    return HiveService.getMoodEntries()
        .map(
          (hive.MoodEntry entry) => domain.MoodEntry(
            id: entry.id,
            score: entry.score,
            feeling: entry.feeling,
            trigger: entry.trigger,
            note: entry.note,
            date: entry.date,
          ),
        )
        .toList(growable: false);
  }

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
