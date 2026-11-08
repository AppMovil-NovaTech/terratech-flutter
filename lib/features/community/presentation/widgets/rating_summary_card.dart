import 'package:flutter/material.dart';

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

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color starAmber = Color(0xFFFFB300);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      StarRatingBar(
                        rating: summary.averageRating,
                        starSize: 20,
                        color: starAmber,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.totalReviews == 0
                            ? 'Sin opiniones aún'
                            : 'Basado en ${summary.totalReviews} ${summary.totalReviews == 1 ? "opinión" : "opiniones"}',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
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
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '$star ★',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: const AlwaysStoppedAnimation<Color>(
                                      primaryGreen,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 26,
                                child: Text(
                                  '$count',
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.grey.shade600,
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
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFEBAA)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFF856404),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Producto con calificación menor a 3.0 estrellas. Te sugerimos revisar las sugerencias de los compradores.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF856404),
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
