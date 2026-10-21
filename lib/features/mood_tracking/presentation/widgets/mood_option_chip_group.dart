import 'package:flutter/material.dart';
import 'package:mood_wiser/core/utilities/app_colors.dart';
import 'package:mood_wiser/core/utilities/app_strings.dart';
import 'package:mood_wiser/features/mood_tracking/data/models/mood_config.dart';

final class MoodOptionChipGroup extends StatefulWidget {
  const MoodOptionChipGroup({
    super.key,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
    this.expandable = false,
  });

  final List<MoodOption> options;
  final Set<String> selectedOptions;
  final ValueChanged<String> onSelectionChanged;
  final bool expandable;

  @override
  State<MoodOptionChipGroup> createState() => _MoodOptionChipGroupState();
}

final class _MoodOptionChipGroupState extends State<MoodOptionChipGroup> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int visibleCount = widget.expandable && !_expanded
            ? _optionsThatFitTwoRows(context, constraints.maxWidth)
            : widget.options.length;
        final List<MoodOption> visibleOptions = widget.options
            .take(visibleCount)
            .toList(growable: false);
        final bool hasMore = visibleCount < widget.options.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: visibleOptions.map(_buildChip).toList(growable: false),
            ),
            if (widget.expandable && (hasMore || _expanded))
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded
                      ? AppStrings.fewerOptions
                      : AppStrings.moreOptions,
                ),
              ),
          ],
        );
      },
    );
  }

  int _optionsThatFitTwoRows(BuildContext context, double maxWidth) {
    final TextDirection textDirection = Directionality.of(context);
    double currentRowWidth = 0;
    int rowCount = 1;
    int visibleCount = 0;

    for (final MoodOption option in widget.options) {
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: option.name,
          style: const TextStyle(color: AppColors.ink),
        ),
        textDirection: textDirection,
      )..layout();
      final double chipWidth = painter.width + 32;
      final double nextWidth = currentRowWidth == 0
          ? chipWidth
          : currentRowWidth + 8 + chipWidth;

      if (nextWidth > maxWidth && currentRowWidth > 0) {
        rowCount++;
        currentRowWidth = chipWidth;
      } else {
        currentRowWidth = nextWidth;
      }

      if (rowCount > 2) {
        break;
      }
      visibleCount++;
    }

    return visibleCount;
  }

  Widget _buildChip(MoodOption option) {
    final bool selected = widget.selectedOptions.contains(option.name);
    return FilterChip(
      label: Text(option.name),
      selected: selected,
      onSelected: (_) => widget.onSelectionChanged(option.name),
      selectedColor: option.color.withValues(alpha: 0.18),
      checkmarkColor: AppColors.ink,
      side: BorderSide(color: selected ? option.color : AppColors.line),
      labelStyle: const TextStyle(color: AppColors.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
