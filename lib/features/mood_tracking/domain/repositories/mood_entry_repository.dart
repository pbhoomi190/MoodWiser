import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_entry.dart';

// Repository interface for managing mood entries. 
//Repositories are responsible for abstracting the data source and providing a consistent API for the domain layer.

// This is a blueprint for the repository at the domain layer. 
// The actual implementation will be in the data layer, which will handle the specifics of data storage and retrieval.
abstract interface class MoodEntryRepository {
  Future<List<MoodEntry>> getAll();

  Future<void> save(MoodEntry entry);
}
