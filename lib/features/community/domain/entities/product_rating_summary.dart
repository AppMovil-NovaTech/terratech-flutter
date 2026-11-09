import 'rating_breakdown.dart';

/// Domain entity representing aggregated reputation and reviews statistics for a product.
class ProductRatingSummary {
  const ProductRatingSummary({
    required this.productId,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.ratingBreakdown = const RatingBreakdown(),
  });

  final int productId;
  final double averageRating;
  final int totalReviews;
  final RatingBreakdown ratingBreakdown;

  /// Whether this product is flagged for low reputation (US34 Scenario 2).
  bool get hasLowReputationAlert => totalReviews > 0 && averageRating < 3.0;

  ProductRatingSummary copyWith({
    int? productId,
    double? averageRating,
    int? totalReviews,
    RatingBreakdown? ratingBreakdown,
  }) {
    return ProductRatingSummary(
      productId: productId ?? this.productId,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      ratingBreakdown: ratingBreakdown ?? this.ratingBreakdown,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductRatingSummary &&
        other.productId == productId &&
        other.averageRating == averageRating &&
        other.totalReviews == totalReviews &&
        other.ratingBreakdown == ratingBreakdown;
  }

  @override
  int get hashCode =>
      Object.hash(productId, averageRating, totalReviews, ratingBreakdown);

  @override
  String toString() {
    return 'ProductRatingSummary(productId: $productId, averageRating: $averageRating, totalReviews: $totalReviews, ratingBreakdown: $ratingBreakdown)';
  }
}
