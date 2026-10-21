import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';
import 'package:mood_wiser/features/mood_tracking/data/models/mood_config.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/save_mood_entry.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/bloc/track_mood_bloc.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/bloc/track_mood_event.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/bloc/track_mood_state.dart';
import 'package:mood_wiser/features/mood_tracking/presentation/widgets/mood_option_chip_group.dart';

final class TrackMoodPage extends StatefulWidget {
  const TrackMoodPage({super.key, required this.saveMoodEntry});

  final SaveMoodEntry saveMoodEntry;

  @override
  State<TrackMoodPage> createState() => _TrackMoodPageState();
}

final class _TrackMoodPageState extends State<TrackMoodPage> {
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TrackMoodBloc>(
      create: (_) => TrackMoodBloc(saveMoodEntry: widget.saveMoodEntry),
      child: BlocListener<TrackMoodBloc, TrackMoodState>(
        listenWhen: (TrackMoodState previous, TrackMoodState current) =>
            previous.saveStatus != current.saveStatus,
        listener: (BuildContext context, TrackMoodState state) {
          // Show a SnackBar message based on the save status of the mood entry.
          final String? message = switch (state.saveStatus) {
            MoodSaveStatus.saved => AppStrings.savedMessage,
            MoodSaveStatus.failure => AppStrings.saveErrorMessage,
            _ => null,
          };
          if (message != null) {
            // After save result reset the state to initial state so that user can track mood again.
            context.read<TrackMoodBloc>().add(const TrackMoodReset());
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        },
        child: BlocBuilder<TrackMoodBloc, TrackMoodState>(
          // BlocBuilder receives the state from the TrackMoodBloc and rebuilds the UI whenever the state changes.
          builder: (BuildContext context, TrackMoodState state) {
            final MoodConfig? config = state.moodConfig;

            return Scaffold(
              appBar: AppBar(
                title: const Text(AppStrings.appTitle),
                centerTitle: false,
              ),
              body: SafeArea(
                top: false,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                  children: <Widget>[
                    Text(
                      AppStrings.trackMoodTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.trackMoodSubtitle,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
                    ),
                    const SizedBox(height: 24),
                    _buildScoreSection(context, state),
                    const SizedBox(height: 26),
                    if (state.optionsStatus != MoodOptionsStatus.loaded ||
                        config == null)
                      _buildConfigStatus(context, state)
                    else ...<Widget>[
                      _buildOptionSection(
                        context: context,
                        label: AppStrings.feelingLabel,
                        options: config.feelings,
                        selectedOptions: state.selectedFeelings,
                        expandable: true,
                        onSelectionChanged: (String name) => context
                            .read<TrackMoodBloc>()
                            .add(TrackMoodFeelingToggled(name)),
                      ),
                      const SizedBox(height: 26),
                      _buildOptionSection(
                        context: context,
                        label: AppStrings.triggerLabel,
                        options: config.triggers,
                        selectedOptions: state.selectedTriggers,
                        expandable: true,
                        onSelectionChanged: (String name) => context
                            .read<TrackMoodBloc>()
                            .add(TrackMoodTriggerToggled(name)),
                      ),
                    ],
                    const SizedBox(height: 22),
                    _buildNoteSection(context),
                    const SizedBox(height: 22),
                    _sectionLabel(context, AppStrings.dateLabel),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () => _chooseDateTime(context, state.date),
                      icon: const Icon(Icons.calendar_today_outlined, size: 18),
                      label: Text(_formatDateTime(context, state.date)),
                      style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.line),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed:
                          state.saveStatus == MoodSaveStatus.saving ||
                              config == null
                          ? null
                          : () => _save(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.saveStatus == MoodSaveStatus.saving
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Text(AppStrings.saveMood),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreSection(BuildContext context, TrackMoodState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(context, AppStrings.scoreLabel),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
          decoration: BoxDecoration(
            color: AppColors.softCoral,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.sentiment_satisfied_alt),
                  const Spacer(),
                  Text(
                    '${state.score} / 10',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Slider(
                value: state.score.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                activeColor: AppColors.accent,
                onChanged: (double value) => context.read<TrackMoodBloc>().add(
                  TrackMoodScoreChanged(value.round()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(AppStrings.scoreLowLabel),
                  Text(AppStrings.scoreHighLabel),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOptionSection({
    required BuildContext context,
    required String label,
    required List<MoodOption> options,
    required Set<String> selectedOptions,
    bool expandable = false,
    required ValueChanged<String> onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(context, label),
        const SizedBox(height: 12),
        MoodOptionChipGroup(
          options: options,
          selectedOptions: selectedOptions,
          onSelectionChanged: onSelectionChanged,
          expandable: expandable,
        ),
      ],
    );
  }

  Widget _buildConfigStatus(BuildContext context, TrackMoodState state) {
    if (state.optionsStatus == MoodOptionsStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: <Widget>[
        Text(AppStrings.optionsLoadError),
        TextButton.icon(
          onPressed: () => context.read<TrackMoodBloc>().add(
            const TrackMoodConfigRequested(),
          ),
          icon: const Icon(Icons.refresh),
          label: const Text(AppStrings.retry),
        ),
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _sectionLabel(context, AppStrings.noteLabel),
        const SizedBox(height: 10),
        TextFormField(
          controller: _noteController,
          minLines: 3,
          maxLines: 5,
          maxLength: 500,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: AppStrings.noteHint,
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime date) {
    final MaterialLocalizations localizations = MaterialLocalizations.of(
      context,
    );
    return '${localizations.formatMediumDate(date)} · '
        '${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(date))}';
  }

  Future<void> _chooseDateTime(BuildContext context, DateTime date) async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (selectedDate == null || !context.mounted) {
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(date),
    );
    if (selectedTime != null && context.mounted) {
      context.read<TrackMoodBloc>().add(
        TrackMoodDateChanged(
          DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          ),
        ),
      );
    }
  }

  void _save(BuildContext context) {
    context.read<TrackMoodBloc>().add(
      TrackMoodSaveRequested(_noteController.text),
    );
  }
}
