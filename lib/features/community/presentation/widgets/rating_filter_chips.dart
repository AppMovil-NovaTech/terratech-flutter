import 'package:flutter/material.dart';

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

  static const Color primaryGreen = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    final total = summary?.totalReviews ?? 0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // "Todas" chip
          _buildChip(
            label: 'Todas ($total)',
            isSelected: selectedRating == null,
            onTap: () => onSelected(null),
          ),
          const SizedBox(width: 8),
          // 5 to 1 star chips
          ...List.generate(5, (index) {
            final star = 5 - index;
            final count = summary?.ratingBreakdown.countForRating(star) ?? 0;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
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
        color: isSelected ? primaryGreen : const Color(0xFF334155),
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? primaryGreen : Colors.grey.shade300,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.white,
      showCheckmark: isSelected,
    );
  }
}
