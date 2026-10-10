import 'package:flutter/material.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/save_mood_entry.dart';

final class TrackMoodPage extends StatefulWidget {
  const TrackMoodPage({super.key, required this.saveMoodEntry});

  final SaveMoodEntry saveMoodEntry;

  @override
  State<TrackMoodPage> createState() => _TrackMoodPageState();
}

final class _TrackMoodPageState extends State<TrackMoodPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _triggerController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _feeling;
  int _score = 5;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _triggerController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: <Widget>[
              Text(
                AppStrings.trackMoodTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
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
              const SizedBox(height: 28),
              _sectionLabel(context, AppStrings.feelingLabel),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppStrings.feelings.map((String feeling) {
                  final bool selected = _feeling == feeling;
                  return ChoiceChip(
                    label: Text(feeling),
                    selected: selected,
                    onSelected: (_) => setState(() => _feeling = feeling),
                    selectedColor: AppColors.softMint,
                    backgroundColor: AppColors.surface,
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.line,
                    ),
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.ink,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }).toList(),
              ),
              if (_feeling == null) ...<Widget>[
                const SizedBox(height: 6),
                Text(
                  AppStrings.feelingRequired,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
                ),
              ],
              const SizedBox(height: 26),
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
                          '$_score / 10',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _score.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      activeColor: AppColors.accent,
                      onChanged: (double value) {
                        setState(() => _score = value.round());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _sectionLabel(context, AppStrings.triggerLabel),
              const SizedBox(height: 10),
              TextFormField(
                controller: _triggerController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: AppStrings.triggerHint,
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.triggerRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 22),
              _sectionLabel(context, AppStrings.noteLabel),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: AppStrings.noteHint,
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 22),
              _sectionLabel(context, AppStrings.dateLabel),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _chooseDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text(
                  MaterialLocalizations.of(context).formatMediumDate(_date),
                ),
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
                onPressed: _isSaving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
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
      ),
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

  Future<void> _chooseDate() async {
    final DateTime now = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (selectedDate != null) {
      setState(() => _date = selectedDate);
    }
  }

  Future<void> _save() async {
    if (_feeling == null || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    try {
      await widget.saveMoodEntry(
        score: _score,
        feeling: _feeling!,
        trigger: _triggerController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
        date: _date,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AppStrings.savedMessage)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.saveErrorMessage)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
