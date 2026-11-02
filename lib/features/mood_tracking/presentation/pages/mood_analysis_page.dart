import 'package:flutter/material.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/core/utilities/app_spacing.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';

enum _AnalysisPeriod { weekly, monthly, yearly }

final class MoodAnalysisPage extends StatefulWidget {
  const MoodAnalysisPage({super.key});

  @override
  State<MoodAnalysisPage> createState() => _MoodAnalysisPageState();
}

final class _MoodAnalysisPageState extends State<MoodAnalysisPage> {
  _AnalysisPeriod _selectedPeriod = _AnalysisPeriod.weekly;

  static const Map<_AnalysisPeriod, _MoodPeriodData> _periodData =
      <_AnalysisPeriod, _MoodPeriodData>{
        _AnalysisPeriod.weekly: _MoodPeriodData(
          labels: <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          scores: <double>[6, 7, 7, 8, 6, 9, 8],
        ),
        _AnalysisPeriod.monthly: _MoodPeriodData(
          labels: <String>['Week 1', 'Week 2', 'Week 3', 'Week 4'],
          scores: <double>[6, 7, 8, 8],
        ),
        _AnalysisPeriod.yearly: _MoodPeriodData(
          labels: <String>[
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ],
          scores: <double>[6, 6, 7, 7, 8, 7, 8, 8, 7, 8, 9, 8],
        ),
      };

  @override
  Widget build(BuildContext context) {
    final _MoodPeriodData data = _periodData[_selectedPeriod]!;
    final double average =
        data.scores.reduce((double sum, double score) => sum + score) /
        data.scores.length;
    final bool isPositiveMood = average >= 7;

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
          SegmentedButton<_AnalysisPeriod>(
            segments: const <ButtonSegment<_AnalysisPeriod>>[
              ButtonSegment(
                value: _AnalysisPeriod.weekly,
                label: Text(AppStrings.weekly),
              ),
              ButtonSegment(
                value: _AnalysisPeriod.monthly,
                label: Text(AppStrings.monthly),
              ),
              ButtonSegment(
                value: _AnalysisPeriod.yearly,
                label: Text(AppStrings.yearly),
              ),
            ],
            selected: <_AnalysisPeriod>{_selectedPeriod},
            onSelectionChanged: (Set<_AnalysisPeriod> selection) {
              setState(() => _selectedPeriod = selection.first);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _AverageMoodCard(average: average),
          const SizedBox(height: AppSpacing.md),
          _MoodChartCard(data: data),
          const SizedBox(height: AppSpacing.md),
          if (isPositiveMood)
            const _InsightCard(
              icon: Icons.celebration_outlined,
              title: AppStrings.positiveMoodTitle,
              message: AppStrings.positiveMoodMessage,
              color: AppColors.softMint,
            ),
          const SizedBox(height: AppSpacing.md),
          const _SummaryCard(
            icon: Icons.mood_outlined,
            title: AppStrings.frequentFeelings,
            detail: AppStrings.feelingInsight,
          ),
          const SizedBox(height: AppSpacing.md),
          const _SummaryCard(
            icon: Icons.favorite_border,
            title: AppStrings.frequentTriggers,
            detail: AppStrings.triggerInsight,
          ),
          const SizedBox(height: AppSpacing.md),
          const _GuidanceCard(),
        ],
      ),
    );
  }
}

final class _MoodPeriodData {
  const _MoodPeriodData({required this.labels, required this.scores});

  final List<String> labels;
  final List<double> scores;
}

final class _AverageMoodCard extends StatelessWidget {
  const _AverageMoodCard({required this.average});

  final double average;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            '${average.toStringAsFixed(1)} ${AppStrings.outOfTen}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

final class _MoodChartCard extends StatelessWidget {
  const _MoodChartCard({required this.data});

  final _MoodPeriodData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.moodTrend,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _MoodChartPainter(scores: data.scores),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.labels
                .map(
                  (String label) => Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.labelSmall?.copyWith(color: AppColors.muted),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

final class _MoodChartPainter extends CustomPainter {
  const _MoodChartPainter({required this.scores});

  final List<double> scores;

  @override
  void paint(Canvas canvas, Size size) {
    const double verticalInset = AppSpacing.sm;
    final double chartHeight = size.height - verticalInset * 2;
    final Paint gridPaint = Paint()
      ..color = AppColors.line
      ..strokeWidth = 1;

    for (int line = 0; line < 5; line++) {
      final double y = verticalInset + chartHeight * line / 4;
      canvas.drawLine(Offset.zero.translate(0, y), Offset(size.width, y), gridPaint);
    }

    if (scores.length < 2) {
      return;
    }

    final List<Offset> points = List<Offset>.generate(scores.length, (
      int index,
    ) {
      final double x = size.width * index / (scores.length - 1);
      final double normalizedScore = (scores[index] - 1) / 9;
      final double y =
          verticalInset + chartHeight * (1 - normalizedScore);
      return Offset(x, y);
    });

    final Path trendPath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      trendPath.lineTo(point.dx, point.dy);
    }

    final Path fillPath = Path.from(trendPath)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            AppColors.softMint.withValues(alpha: 0.9),
            AppColors.softMint.withValues(alpha: 0.05),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      trendPath,
      Paint()
        ..color = AppColors.primary
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    for (final Offset point in points) {
      canvas.drawCircle(point, 4, Paint()..color = AppColors.surface);
      canvas.drawCircle(
        point,
        3,
        Paint()
          ..color = AppColors.primary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_MoodChartPainter oldDelegate) =>
      oldDelegate.scores != scores;
}

final class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  detail,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _GuidanceCard extends StatelessWidget {
  const _GuidanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppStrings.whatHelps,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.wellnessSuggestion,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.difficultDaySuggestion,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AppColors.line),
  );
}

final class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
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
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
