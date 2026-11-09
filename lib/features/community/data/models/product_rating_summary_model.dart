import '../../domain/entities/product_rating_summary.dart';
import 'rating_breakdown_model.dart';

/// Data transfer model for [ProductRatingSummary] mapping JSON responses from
/// `GET /api/v1/products/{productId}/ratings-summary`.
class ProductRatingSummaryModel extends ProductRatingSummary {
  const ProductRatingSummaryModel({
    required super.productId,
    super.averageRating = 0.0,
    super.totalReviews = 0,
    super.ratingBreakdown = const RatingBreakdownModel(),
  });

  factory ProductRatingSummaryModel.fromJson(Map<String, dynamic> json) {
    final breakdownJson = json['ratingBreakdown'];
    final breakdown = breakdownJson is Map<String, dynamic>
        ? RatingBreakdownModel.fromJson(breakdownJson)
        : const RatingBreakdownModel();

    return ProductRatingSummaryModel(
      productId: (json['productId'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      ratingBreakdown: breakdown,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'productId': productId,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'ratingBreakdown': (ratingBreakdown is RatingBreakdownModel)
          ? (ratingBreakdown as RatingBreakdownModel).toJson()
          : RatingBreakdownModel.fromEntity(ratingBreakdown).toJson(),
    };
  }

  factory ProductRatingSummaryModel.fromEntity(ProductRatingSummary entity) {
    return ProductRatingSummaryModel(
      productId: entity.productId,
      averageRating: entity.averageRating,
      totalReviews: entity.totalReviews,
      ratingBreakdown: entity.ratingBreakdown,
    );
  }
}
