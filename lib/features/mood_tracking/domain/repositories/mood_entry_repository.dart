import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';

abstract interface class MoodEntryRepository {
  Future<void> save(MoodEntry entry);
}
