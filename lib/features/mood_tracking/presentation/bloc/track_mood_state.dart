import 'package:mood_wiser/features/mood_tracking/data/models/mood_config.dart';

enum MoodOptionsStatus { loading, loaded, failure }

enum MoodSaveStatus { idle, saving, saved, failure }

/// Represents the state of the mood tracking feature,
/// including the loaded mood configuration, selected options, score, date, and save status.
/// any changes to the state are made through the `copyWith` method, which creates a new instance with updated values.
/// copyWith method is used to create a new instance of the state with updated values, while keeping the existing values for properties that are not changed.
final class TrackMoodState {
  TrackMoodState({
    this.moodConfig,
    this.optionsStatus = MoodOptionsStatus.loading,
    this.score = 5,
    Set<String> selectedFeelings = const <String>{},
    Set<String> selectedTriggers = const <String>{},
    DateTime? date,
    this.saveStatus = MoodSaveStatus.idle,
  }) : selectedFeelings = Set<String>.unmodifiable(selectedFeelings),
       selectedTriggers = Set<String>.unmodifiable(selectedTriggers),
       date = date ?? DateTime.now();

  final MoodConfig? moodConfig;
  final MoodOptionsStatus optionsStatus;
  final int score;
  final Set<String> selectedFeelings;
  final Set<String> selectedTriggers;
  final DateTime date;
  final MoodSaveStatus saveStatus;

  TrackMoodState copyWith({
    MoodConfig? moodConfig,
    MoodOptionsStatus? optionsStatus,
    int? score,
    Set<String>? selectedFeelings,
    Set<String>? selectedTriggers,
    DateTime? date,
    MoodSaveStatus? saveStatus,
  }) {
    return TrackMoodState(
      moodConfig: moodConfig ?? this.moodConfig,
      optionsStatus: optionsStatus ?? this.optionsStatus,
      score: score ?? this.score,
      selectedFeelings: selectedFeelings ?? this.selectedFeelings,
      selectedTriggers: selectedTriggers ?? this.selectedTriggers,
      date: date ?? this.date,
      saveStatus: saveStatus ?? this.saveStatus,
    );
  }
}
