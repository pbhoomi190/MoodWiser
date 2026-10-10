import 'package:mood_wiser/features/mood_tracking/data/data_sources/hive_mood_entry_local_data_source.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/domain/repositories/mood_entry_repository.dart';

final class MoodEntryRepositoryImpl implements MoodEntryRepository {
  const MoodEntryRepositoryImpl(this._localDataSource);

  final HiveMoodEntryLocalDataSource _localDataSource;

  @override
  Future<void> save(MoodEntry entry) {
    return _localDataSource.save(entry);
  }
}
