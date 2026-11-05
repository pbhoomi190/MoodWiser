import 'package:flutter/material.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/core/utilities/app_spacing.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';
import 'package:mood_wiser/features/mood_tracking/domain/entities/mood_analysis.dart';
import 'package:mood_wiser/features/mood_tracking/domain/use_cases/analyze_mood_entries.dart';

final class MoodAnalysisPage extends StatefulWidget {
  const MoodAnalysisPage({super.key, required this.analyzeMoodEntries});

  // Use case for analyzing mood entries.
  final AnalyzeMoodEntries analyzeMoodEntries;

  @override
  State<MoodAnalysisPage> createState() => _MoodAnalysisPageState();
}

final class _MoodAnalysisPageState extends State<MoodAnalysisPage> {
  MoodAnalysisPeriod _selectedPeriod = MoodAnalysisPeriod.weekly;
  late Future<MoodAnalysis> _analysis;

  @override
  void initState() {
    super.initState();
    _analysis = _loadAnalysis();
  }

  Future<MoodAnalysis> _loadAnalysis() {
    return widget.analyzeMoodEntries(period: _selectedPeriod);
  }

  void _selectPeriod(MoodAnalysisPeriod period) {
    setState(() {
      _selectedPeriod = period;
      _analysis = _loadAnalysis();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.moodAnalysisTitle),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xlg,
          AppSpacing.md,
          AppSpacing.xlg,
          AppSpacing.xxlg,
        ),
        children: <Widget>[
          Text(
            AppStrings.moodAnalysisSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.xlg),
          SegmentedButton<MoodAnalysisPeriod>(
            segments: const <ButtonSegment<MoodAnalysisPeriod>>[
              ButtonSegment(
                value: MoodAnalysisPeriod.weekly,
                label: Text(AppStrings.weekly),
              ),
              ButtonSegment(
                value: MoodAnalysisPeriod.monthly,
                label: Text(AppStrings.monthly),
              ),
              ButtonSegment(
                value: MoodAnalysisPeriod.yearly,
                label: Text(AppStrings.yearly),
              ),
            ],
            selected: <MoodAnalysisPeriod>{_selectedPeriod},
            onSelectionChanged: (Set<MoodAnalysisPeriod> selection) {
              _selectPeriod(selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          FutureBuilder<MoodAnalysis>(
            future: _analysis,
            builder:
                (BuildContext context, AsyncSnapshot<MoodAnalysis> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return _MessageCard(message: AppStrings.analysisLoadError);
                  }
                  final MoodAnalysis? analysis = snapshot.data;
                  if (analysis == null) {
                    return _MessageCard(message: AppStrings.analysisLoadError);
                  }
                  if (analysis.totalEntries == 0) {
                    return _MessageCard(
                      message: AppStrings.noMoodEntryHighlights,
                    );
                  }
                  return _AnalysisResults(analysis: analysis);
                },
          ),
        ],
      ),
    );
  }
}

final class _AnalysisResults extends StatelessWidget {
  const _AnalysisResults({required this.analysis});

  final MoodAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final String average = analysis.averageMood!.toStringAsFixed(1);
    final String volatility = analysis.volatility;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.softCoral,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.sentiment_satisfied_alt, color: AppColors.ink),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppStrings.averageMood,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$average ${AppStrings.outOfTen}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _DataCard(
          title: AppStrings.moodTrend,
          rows: <String>[
            '${AppStrings.totalEntries}: ${analysis.totalEntries}',
            analysis.trend,
            '${AppStrings.volatility}: $volatility',
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _TriggerImpactCard(
          title: AppStrings.positiveCatalysts,
          emptyMessage: AppStrings.noSignificantTriggers,
          impacts: analysis.positiveTriggers,
        ),
        const SizedBox(height: AppSpacing.md),
        _TriggerImpactCard(
          title: AppStrings.negativeFriction,
          emptyMessage: AppStrings.noSignificantTriggers,
          impacts: analysis.negativeTriggers,
        ),
        const SizedBox(height: AppSpacing.md),
        _DataCard(
          title: AppStrings.frequentFeelings,
          rows: analysis.topFeelings,
          emptyMessage: AppStrings.noFeelingData,
        ),
        const SizedBox(height: AppSpacing.md),
        _MoodEntryHighlightsCard(samples: analysis.entryHighlights),
        const SizedBox(height: AppSpacing.md),
        _PayloadCard(payload: analysis.toJson()),
      ],
    );
  }
}

final class _TriggerImpactCard extends StatelessWidget {
  const _TriggerImpactCard({
    required this.title,
    required this.emptyMessage,
    required this.impacts,
  });

  final String title;
  final String emptyMessage;
  final List<MoodTriggerImpact> impacts;

  @override
  Widget build(BuildContext context) {
    final List<String> rows = impacts
        .map(
          (MoodTriggerImpact impact) =>
              '${impact.trigger} — ${impact.deltaLabel} '
              '(${impact.frequency}x)',
        )
        .toList(growable: false);
    return _DataCard(title: title, rows: rows, emptyMessage: emptyMessage);
  }
}

final class _MoodEntryHighlightsCard extends StatelessWidget {
  const _MoodEntryHighlightsCard({required this.samples});

  final List<MoodEntryHighlight> samples;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.moodEntryHighlights,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (samples.isEmpty)
            Text(
              AppStrings.noMoodEntryHighlights,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            )
          else
            ...samples.map((MoodEntryHighlight sample) {
              final String date = MaterialLocalizations.of(
                context,
              ).formatShortDate(sample.date);
              final List<String> details = <String>[
                '$date · ${sample.mood} ${AppStrings.outOfTen}',
                '${sample.feelings} · ${sample.trigger}',
                if (sample.note case final String note when note.isNotEmpty)
                  note,
              ];
              return Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  details.join('\n'),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              );
            }),
        ],
      ),
    );
  }
}

final class _DataCard extends StatelessWidget {
  const _DataCard({
    required this.title,
    required this.rows,
    this.emptyMessage = AppStrings.noFeelingData,
  });

  final String title;
  final List<String> rows;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (rows.isEmpty)
            Text(
              emptyMessage,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
            )
          else
            ...rows.map(
              (String row) => Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  row,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

final class _PayloadCard extends StatelessWidget {
  const _PayloadCard({required this.payload});

  final String payload;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: ExpansionTile(
        title: const Text(AppStrings.analysisPayload),
        childrenPadding: const EdgeInsets.all(AppSpacing.lg),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SelectableText(
            payload,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

final class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Text(
        message,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
      ),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
  color: AppColors.surface,
  borderRadius: BorderRadius.circular(14),
  border: Border.all(color: AppColors.line),
);
