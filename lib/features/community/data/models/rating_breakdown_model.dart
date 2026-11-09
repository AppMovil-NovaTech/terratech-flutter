import '../../domain/entities/rating_breakdown.dart';

/// Data transfer model for [RatingBreakdown] matching the backend breakdown payload.
class RatingBreakdownModel extends RatingBreakdown {
  const RatingBreakdownModel({
    super.oneStar = 0,
    super.twoStars = 0,
    super.threeStars = 0,
    super.fourStars = 0,
    super.fiveStars = 0,
  });

  factory RatingBreakdownModel.fromJson(Map<String, dynamic> json) {
    return RatingBreakdownModel(
      oneStar: (json['oneStar'] as num?)?.toInt() ?? 0,
      twoStars: (json['twoStars'] as num?)?.toInt() ?? 0,
      threeStars: (json['threeStars'] as num?)?.toInt() ?? 0,
      fourStars: (json['fourStars'] as num?)?.toInt() ?? 0,
      fiveStars: (json['fiveStars'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'oneStar': oneStar,
      'twoStars': twoStars,
      'threeStars': threeStars,
      'fourStars': fourStars,
      'fiveStars': fiveStars,
    };
  }

  factory RatingBreakdownModel.fromEntity(RatingBreakdown entity) {
    return RatingBreakdownModel(
      oneStar: entity.oneStar,
      twoStars: entity.twoStars,
      threeStars: entity.threeStars,
      fourStars: entity.fourStars,
      fiveStars: entity.fiveStars,
    );
  }
}
