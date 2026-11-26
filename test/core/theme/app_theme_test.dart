import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/core/router/app_routes.dart';
import 'package:terratech_mobile/core/theme/app_colors.dart';
import 'package:terratech_mobile/core/theme/app_spacing.dart';
import 'package:terratech_mobile/core/theme/app_theme.dart';

void main() {
  group('AppTheme & Design Tokens', () {
    test('AppTheme.light configures Material 3 and TerraTech palette', () {
      final theme = AppTheme.light();

      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.secondary, equals(AppColors.secondary));
      expect(theme.colorScheme.surface, equals(AppColors.surface));
      expect(
        theme.scaffoldBackgroundColor,
        equals(AppColors.scaffoldBackground),
      );
      expect(theme.cardTheme.color, equals(AppColors.surface));
      expect(theme.inputDecorationTheme.filled, isTrue);
      expect(theme.bottomSheetTheme.backgroundColor, equals(AppColors.surface));
      expect(
        theme.snackBarTheme.behavior,
        equals(SnackBarBehavior.floating),
      );
    });

    test('AppSpacing tokens follow strictly increasing scale', () {
      expect(AppSpacing.xxs, lessThan(AppSpacing.xs));
      expect(AppSpacing.xs, lessThan(AppSpacing.sm));
      expect(AppSpacing.sm, lessThan(AppSpacing.md));
      expect(AppSpacing.md, lessThan(AppSpacing.lg));
      expect(AppSpacing.lg, lessThan(AppSpacing.xl));
      expect(AppSpacing.xl, lessThan(AppSpacing.xxl));
      expect(AppSpacing.xxl, lessThan(AppSpacing.xxxl));

      expect(AppSpacing.radiusSm, lessThan(AppSpacing.radiusMd));
      expect(AppSpacing.radiusMd, lessThan(AppSpacing.radiusLg));
      expect(AppSpacing.radiusLg, lessThan(AppSpacing.radiusXl));
      expect(AppSpacing.radiusXl, lessThan(AppSpacing.radiusPill));
    });

    testWidgets(
      'TerraTechHomeShell renders module cards with expected keys and labels',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light(),
            home: const TerraTechHomeShell(),
          ),
        );

        expect(find.text('TerraTech Home'), findsOneWidget);
        expect(find.text('Plataforma Agroecológica TerraTech'), findsOneWidget);
        expect(
          find.byKey(const Key('home_navigate_commercial_card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('home_navigate_community_card')),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Ir al catálogo de productos y trazabilidad'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel(
            'Ir a comunidad agrícola y reseñas de productores',
          ),
          findsOneWidget,
        );
      },
    );
  });
}
