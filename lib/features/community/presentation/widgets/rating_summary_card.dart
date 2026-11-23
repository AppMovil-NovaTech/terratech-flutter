import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/product_rating_summary.dart';
import 'star_rating_bar.dart';

/// Card widget displaying overall product rating, star breakdown histogram,
/// and low rating warning banner (US34).
class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({
    super.key,
    required this.summary,
    this.onRatingBarTap,
  });

  final ProductRatingSummary summary;
  final ValueChanged<int>? onRatingBarTap;

  static const Color primaryGreen = AppColors.primary;
  static const Color starAmber = AppColors.starGold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Left side: Large average rating & stars
                Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        summary.averageRating.toStringAsFixed(1),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      StarRatingBar(
                        rating: summary.averageRating,
                        starSize: 20,
                        color: starAmber,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        summary.totalReviews == 0
                            ? 'Sin opiniones aún'
                            : 'Basado en ${summary.totalReviews} ${summary.totalReviews == 1 ? "opinión" : "opiniones"}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                // Right side: 5 to 1 star histogram bars
                Expanded(
                  flex: 6,
                  child: Column(
                    children: List.generate(5, (index) {
                      final star = 5 - index;
                      final count = summary.ratingBreakdown.countForRating(star);
                      final progress = summary.totalReviews > 0
                          ? count / summary.totalReviews
                          : 0.0;

                      return InkWell(
                        onTap: (onRatingBarTap != null && count > 0)
                            ? () => onRatingBarTap!(star)
                            : null,
                        borderRadius: BorderRadius.circular(AppSpacing.xs),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxs,
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '$star ★',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.xs,
                                  ),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: AppColors.surfaceMuted,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              SizedBox(
                                width: 26,
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
            // Low reputation alert banner (US34 Scenario 2)
            if (summary.hasLowReputationAlert) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.warningBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: AppColors.warningBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warningForeground,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Producto con calificación menor a 3.0 estrellas. Te sugerimos revisar las sugerencias de los compradores.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warningForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
