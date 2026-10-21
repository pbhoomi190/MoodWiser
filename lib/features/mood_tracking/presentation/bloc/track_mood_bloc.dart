import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_wiser/features/mood_tracking/data/models/mood_config.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/save_mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/bloc/track_mood_event.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/bloc/track_mood_state.dart';

/// A BLoC that manages the state of the mood tracking feature.
/// Decides how to respond to events and update the state accordingly.
final class TrackMoodBloc extends Bloc<TrackMoodEvent, TrackMoodState> {
  TrackMoodBloc({required SaveMoodEntry saveMoodEntry})
    : _saveMoodEntry = saveMoodEntry,
      super(TrackMoodState()) {
    on<TrackMoodConfigRequested>(_onConfigRequested);
    on<TrackMoodScoreChanged>(_onScoreChanged);
    on<TrackMoodFeelingToggled>(_onFeelingToggled);
    on<TrackMoodTriggerToggled>(_onTriggerToggled);
    on<TrackMoodDateChanged>(_onDateChanged);
    on<TrackMoodSaveRequested>(_onSaveRequested);
    on<TrackMoodReset>(_onReset);
    add(const TrackMoodConfigRequested());
  }

  final SaveMoodEntry _saveMoodEntry;

  Future<void> _onConfigRequested(
    TrackMoodConfigRequested event,
    Emitter<TrackMoodState> emit,
  ) async {
    emit(state.copyWith(optionsStatus: MoodOptionsStatus.loading));
    try {
      final MoodConfig config = await MoodConfig.load();
      if (!emit.isDone) {
        emit(
          state.copyWith(
            moodConfig: config,
            optionsStatus: MoodOptionsStatus.loaded,
          ),
        );
      }
    } catch (_) {
      if (!emit.isDone) {
        emit(state.copyWith(optionsStatus: MoodOptionsStatus.failure));
      }
    }
  }

  void _onScoreChanged(
    TrackMoodScoreChanged event,
    Emitter<TrackMoodState> emit,
  ) {
    // Update the state with the new mood score when the score changes.
    // copyWith method is used to create a new instance of the state with updated values,
    // while keeping the existing values for properties that are not changed.
    // this ensures that no previous state is lost when updating the score.
    emit(state.copyWith(score: event.score));
  }

  void _onFeelingToggled(
    TrackMoodFeelingToggled event,
    Emitter<TrackMoodState> emit,
  ) {
    final Set<String> feelings = <String>{...state.selectedFeelings};
    if (!feelings.add(event.feeling)) {
      feelings.remove(event.feeling);
    }
    emit(
      state.copyWith(
        selectedFeelings: feelings,
      ),
    );
  }

  void _onTriggerToggled(
    TrackMoodTriggerToggled event,
    Emitter<TrackMoodState> emit,
  ) {
    final Set<String> triggers = <String>{...state.selectedTriggers};
    if (!triggers.add(event.trigger)) {
      triggers.remove(event.trigger);
    }
    emit(
      state.copyWith(
        selectedTriggers: triggers,
      ),
    );
  }

  void _onDateChanged(
    TrackMoodDateChanged event,
    Emitter<TrackMoodState> emit,
  ) {
    emit(state.copyWith(date: event.date));
  }

  Future<void> _onSaveRequested(
    TrackMoodSaveRequested event,
    Emitter<TrackMoodState> emit,
  ) async {
    final TrackMoodState submittedState = state;
    final MoodConfig? config = submittedState.moodConfig;
    if (config == null || submittedState.saveStatus == MoodSaveStatus.saving) {
      return;
    }

    emit(state.copyWith(saveStatus: MoodSaveStatus.saving));
    try {
      final String trimmedNote = event.note.trim();
      await _saveMoodEntry(
        score: submittedState.score,
        feeling: _joinSelections(
          config.feelings,
          submittedState.selectedFeelings,
        ),
        trigger: _joinSelections(
          config.triggers,
          submittedState.selectedTriggers,
        ),
        note: trimmedNote.isEmpty ? null : trimmedNote,
        date: submittedState.date,
      );
      if (!emit.isDone) {
        emit(state.copyWith(saveStatus: MoodSaveStatus.saved));
      }
    } catch (_) {
      if (!emit.isDone) {
        emit(state.copyWith(saveStatus: MoodSaveStatus.failure));
      }
    }
  }

  void _onReset(
    TrackMoodReset event,
    Emitter<TrackMoodState> emit,
  ) {
    emit(state.copyWith(
      score: 1,
      selectedFeelings: <String>{},
      selectedTriggers: <String>{},
      date: DateTime.now(),
      saveStatus: MoodSaveStatus.idle,
    ));
  }

  String _joinSelections(List<MoodOption> options, Set<String> selected) {
    return options
        .where((MoodOption option) => selected.contains(option.name))
        .map((MoodOption option) => option.name)
        .join(', ');
  }

}
