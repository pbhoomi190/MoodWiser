final class MoodEntry {
  const MoodEntry({
    this.id,
    required this.score,
    required this.feeling,
    required this.trigger,
    this.note,
    required this.date,
  });

  final int? id;
  final int score;
  final String feeling;
  final String trigger;
  final String? note;
  final DateTime date;
}
