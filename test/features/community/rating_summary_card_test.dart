import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/features/community/domain/entities/product_rating_summary.dart';
import 'package:terratech_mobile/features/community/domain/entities/rating_breakdown.dart';
import 'package:terratech_mobile/features/community/presentation/widgets/rating_summary_card.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    );
  }

  group('RatingSummaryCard Widget Tests', () {
    testWidgets('Renders average rating and reviews count', (tester) async {
      const summary = ProductRatingSummary(
        productId: 104,
        averageRating: 4.5,
        totalReviews: 8,
        ratingBreakdown: RatingBreakdown(fiveStars: 5, fourStars: 3),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingSummaryCard(summary: summary),
        ),
      );

      expect(find.text('4.5'), findsOneWidget);
      expect(find.text('Basado en 8 opiniones'), findsOneWidget);
      expect(find.text('5 ★'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Low reputation alert banner should not be displayed
      expect(
        find.textContaining('calificación menor a 3.0 estrellas'),
        findsNothing,
      );
    });

    testWidgets('Displays low reputation warning banner when rating < 3.0 (US34 Scenario 2)', (tester) async {
      const lowSummary = ProductRatingSummary(
        productId: 104,
        averageRating: 2.3,
        totalReviews: 4,
        ratingBreakdown: RatingBreakdown(twoStars: 2, oneStar: 2),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingSummaryCard(summary: lowSummary),
        ),
      );

      expect(find.text('2.3'), findsOneWidget);
      expect(find.text('Basado en 4 opiniones'), findsOneWidget);
      expect(
        find.textContaining('calificación menor a 3.0 estrellas'),
        findsOneWidget,
      );
    });

    testWidgets('Does not display alert banner when totalReviews is 0', (tester) async {
      const emptySummary = ProductRatingSummary(
        productId: 104,
        averageRating: 0.0,
        totalReviews: 0,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          const RatingSummaryCard(summary: emptySummary),
        ),
      );

      expect(find.text('Sin opiniones aún'), findsOneWidget);
      expect(
        find.textContaining('calificación menor a 3.0 estrellas'),
        findsNothing,
      );
    });

    testWidgets('Fires onRatingBarTap when star row is tapped', (tester) async {
      int? tappedStar;
      const summary = ProductRatingSummary(
        productId: 104,
        averageRating: 4.0,
        totalReviews: 2,
        ratingBreakdown: RatingBreakdown(fiveStars: 2),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          RatingSummaryCard(
            summary: summary,
            onRatingBarTap: (star) => tappedStar = star,
          ),
        ),
      );

      await tester.tap(find.text('5 ★'));
      await tester.pump();

      expect(tappedStar, 5);
    });
  });
}
