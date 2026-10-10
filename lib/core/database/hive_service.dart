import 'package:hive_flutter/hive_flutter.dart';
import 'package:mood_wiser/core/database/entities/mood_entry.dart';

final class HiveService {
  const HiveService._();

  static const String moodEntriesBoxName = 'mood_entries';

  static Box<MoodEntry>? _moodEntriesBox;

  static Box<MoodEntry> get _box {
    final Box<MoodEntry>? box = _moodEntriesBox;
    if (box == null || !box.isOpen) {
      throw StateError('HiveService must be initialized before use.');
    }
    return box;
  }

  static Future<int> addMoodEntry(MoodEntry entry) async {
    final int key = await _box.add(entry);
    entry.id = key;
    await entry.save();
    return key;
  }

  static Future<void> updateMoodEntry(int id, MoodEntry entry) async {
    entry.id = id;
    await _box.put(id, entry);
  }

  static Future<void> deleteMoodEntry(int id) async {
    await _box.delete(id);
  }

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MoodEntryAdapter());
    }
    _moodEntriesBox = await Hive.openBox<MoodEntry>(moodEntriesBoxName);
  }
}
