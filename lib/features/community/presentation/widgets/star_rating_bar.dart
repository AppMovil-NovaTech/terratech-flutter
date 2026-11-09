import 'package:flutter/material.dart';

/// Reusable star rating bar displaying 5 stars (filled, half, or empty)
/// according to the provided [rating].
class StarRatingBar extends StatelessWidget {
  const StarRatingBar({
    super.key,
    required this.rating,
    this.starSize = 20.0,
    this.color = const Color(0xFFFFB300),
    this.emptyColor = const Color(0xFFBDBDBD),
  });

  final double rating;
  final double starSize;
  final Color color;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final IconData icon;
        final Color starColor;

        if (rating >= starValue) {
          icon = Icons.star;
          starColor = color;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
          starColor = color;
        } else {
          icon = Icons.star_border;
          starColor = emptyColor;
        }

        return Icon(
          icon,
          size: starSize,
          color: starColor,
        );
      }),
    );
  }
}
