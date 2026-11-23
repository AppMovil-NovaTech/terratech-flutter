import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product_rating_summary.dart';

/// Horizontal scrollable bar of rating filter chips (US33 Scenario 2, US36 Scenario 3).
class RatingFilterChips extends StatelessWidget {
  const RatingFilterChips({
    super.key,
    required this.selectedRating,
    this.summary,
    required this.onSelected,
  });

  final int? selectedRating;
  final ProductRatingSummary? summary;
  final ValueChanged<int?> onSelected;

  static const Color primaryGreen = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final total = summary?.totalReviews ?? 0;
    final availableStars = <int>[5, 4, 3, 2, 1].where((star) {
      if (summary == null) return true;
      final count = summary!.ratingBreakdown.countForRating(star);
      return count > 0 || selectedRating == star;
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          // "Todas" chip
          _buildChip(
            label: 'Todas ($total)',
            isSelected: selectedRating == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Star chips with existing reviews
          ...availableStars.map((star) {
            final count = summary?.ratingBreakdown.countForRating(star) ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _buildChip(
                label: '$star ★ ($count)',
                isSelected: selectedRating == star,
                onTap: () => onSelected(star),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: primaryGreen.withValues(alpha: 0.15),
      checkmarkColor: primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? primaryGreen : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? primaryGreen : AppColors.border,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      backgroundColor: AppColors.surface,
      showCheckmark: isSelected,
    );
  }
}
