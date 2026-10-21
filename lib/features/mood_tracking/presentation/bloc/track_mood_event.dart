sealed class TrackMoodEvent {
  const TrackMoodEvent();
}

final class TrackMoodConfigRequested extends TrackMoodEvent {
  const TrackMoodConfigRequested();
}

final class TrackMoodScoreChanged extends TrackMoodEvent {
  const TrackMoodScoreChanged(this.score);

  final int score;
}

final class TrackMoodFeelingToggled extends TrackMoodEvent {
  const TrackMoodFeelingToggled(this.feeling);

  final String feeling;
}

final class TrackMoodTriggerToggled extends TrackMoodEvent {
  const TrackMoodTriggerToggled(this.trigger);

  final String trigger;
}

final class TrackMoodDateChanged extends TrackMoodEvent {
  const TrackMoodDateChanged(this.date);

  final DateTime date;
}

final class TrackMoodSaveRequested extends TrackMoodEvent {
  const TrackMoodSaveRequested(this.note);

  final String note;
}

final class TrackMoodReset extends TrackMoodEvent {
  const TrackMoodReset();
}
