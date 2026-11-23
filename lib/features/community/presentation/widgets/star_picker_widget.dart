import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Interactive 5-star rating picker widget for review creation and editing (US35).
class StarPickerWidget extends StatelessWidget {
  const StarPickerWidget({
    super.key,
    required this.rating,
    required this.onRatingChanged,
    this.starSize = 36.0,
    this.activeColor = AppColors.starGold,
    this.inactiveColor = AppColors.surfaceMuted,
  });

  final int rating;
  final ValueChanged<int> onRatingChanged;
  final double starSize;
  final Color activeColor;
  final Color inactiveColor;

  static const List<String> _ratingLabels = [
    'Malo',
    'Regular',
    'Bueno',
    'Muy bueno',
    'Excelente',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelIndex = (rating - 1).clamp(0, 4);
    final currentLabel = _ratingLabels[labelIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final starNumber = index + 1;
            final isFilled = starNumber <= rating;

            return IconButton(
              key: Key('star_picker_$starNumber'),
              onPressed: () => onRatingChanged(starNumber),
              iconSize: starSize,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              constraints: const BoxConstraints(),
              icon: Icon(
                isFilled ? Icons.star : Icons.star_border,
                color: isFilled ? activeColor : inactiveColor,
              ),
              tooltip: '$starNumber estrellas',
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          currentLabel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: activeColor == AppColors.starGold
                ? AppColors.starLabelDeep
                : activeColor,
          ),
        ),
      ],
    );
  }
}
