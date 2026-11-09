import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/features/community/domain/entities/comment.dart';
import 'package:terratech_mobile/features/community/presentation/widgets/review_input_bottom_sheet.dart';

void main() {
  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('ReviewInputBottomSheet Widget Tests', () {
    testWidgets('Renders create mode elements with default 5 stars', (tester) async {
      await tester.pumpWidget(
        buildTestableWidget(
          ReviewInputBottomSheet(
            onSubmit: ({required content, required rating}) async => true,
          ),
        ),
      );

      expect(find.text('Escribe tu opinión'), findsOneWidget);
      expect(find.text('Excelente'), findsOneWidget);
      expect(find.byKey(const Key('review_content_input')), findsOneWidget);
      expect(find.text('Publicar reseña'), findsOneWidget);
    });

    testWidgets('Rejects input shorter than 10 chars with validation error (US35 Scenario 2)', (tester) async {
      bool submitted = false;

      await tester.pumpWidget(
        buildTestableWidget(
          ReviewInputBottomSheet(
            onSubmit: ({required content, required rating}) async {
              submitted = true;
              return true;
            },
          ),
        ),
      );

      // Enter short text
      await tester.enterText(
        find.byKey(const Key('review_content_input')),
        'Muy malo',
      );
      await tester.tap(find.byKey(const Key('review_submit_button')));
      await tester.pump();

      expect(
        find.text('La reseña debe contener al menos 10 caracteres para ser publicada.'),
        findsOneWidget,
      );
      expect(submitted, isFalse);
    });

    testWidgets('Submits valid review with selected rating and content', (tester) async {
      String? submittedContent;
      int? submittedRating;

      await tester.pumpWidget(
        buildTestableWidget(
          ReviewInputBottomSheet(
            onSubmit: ({required content, required rating}) async {
              submittedContent = content;
              submittedRating = rating;
              return true;
            },
          ),
        ),
      );

      // Tap on 4 stars
      await tester.tap(find.byKey(const Key('star_picker_4')));
      await tester.pump();
      expect(find.text('Muy bueno'), findsOneWidget);

      // Enter valid text (>= 10 chars)
      await tester.enterText(
        find.byKey(const Key('review_content_input')),
        'Excelente fertilizante para floración rápida.',
      );
      await tester.tap(find.byKey(const Key('review_submit_button')));
      await tester.pump();

      expect(submittedRating, 4);
      expect(submittedContent, 'Excelente fertilizante para floración rápida.');
    });

    testWidgets('Renders edit mode correctly with pre-filled comment', (tester) async {
      final existingComment = Comment(
        id: 7,
        userId: 5,
        productId: 104,
        targetProfileId: 2,
        content: 'Contenido previo de la reseña para editar.',
        rating: 3,
        createdAt: DateTime.now(),
        authorName: 'Carlos M.',
      );

      await tester.pumpWidget(
        buildTestableWidget(
          ReviewInputBottomSheet(
            initialComment: existingComment,
            onSubmit: ({required content, required rating}) async => true,
          ),
        ),
      );

      expect(find.text('Editar tu opinión'), findsOneWidget);
      expect(find.text('Bueno'), findsOneWidget);
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(
        find.text('Contenido previo de la reseña para editar.'),
        findsOneWidget,
      );
    });
  });
}
