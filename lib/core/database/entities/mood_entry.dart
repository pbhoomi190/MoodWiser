import 'package:hive/hive.dart';

part 'mood_entry.g.dart';

@HiveType(typeId: 0)
class MoodEntry extends HiveObject {
  MoodEntry({
    required this.id,
    required this.score,
    required this.feeling,
    required this.trigger,
    this.note,
    required this.date,
  });

  @HiveField(0)
  int id;

  @HiveField(1)
  int score;

  @HiveField(2)
  String feeling;

  @HiveField(3)
  String trigger;

  @HiveField(4)
  String? note;

  @HiveField(5)
  DateTime date;
}
