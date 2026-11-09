/// Domain entity representing the distribution of ratings across 1 to 5 stars.
class RatingBreakdown {
  const RatingBreakdown({
    this.oneStar = 0,
    this.twoStars = 0,
    this.threeStars = 0,
    this.fourStars = 0,
    this.fiveStars = 0,
  });

  final int oneStar;
  final int twoStars;
  final int threeStars;
  final int fourStars;
  final int fiveStars;

  /// Returns the number of reviews for a specific star rating [1..5].
  int countForRating(int stars) {
    return switch (stars) {
      5 => fiveStars,
      4 => fourStars,
      3 => threeStars,
      2 => twoStars,
      1 => oneStar,
      _ => 0,
    };
  }

  RatingBreakdown copyWith({
    int? oneStar,
    int? twoStars,
    int? threeStars,
    int? fourStars,
    int? fiveStars,
  }) {
    return RatingBreakdown(
      oneStar: oneStar ?? this.oneStar,
      twoStars: twoStars ?? this.twoStars,
      threeStars: threeStars ?? this.threeStars,
      fourStars: fourStars ?? this.fourStars,
      fiveStars: fiveStars ?? this.fiveStars,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RatingBreakdown &&
        other.oneStar == oneStar &&
        other.twoStars == twoStars &&
        other.threeStars == threeStars &&
        other.fourStars == fourStars &&
        other.fiveStars == fiveStars;
  }

  @override
  int get hashCode => Object.hash(
    oneStar,
    twoStars,
    threeStars,
    fourStars,
    fiveStars,
  );

  @override
  String toString() {
    return 'RatingBreakdown(1: $oneStar, 2: $twoStars, 3: $threeStars, 4: $fourStars, 5: $fiveStars)';
  }
}
