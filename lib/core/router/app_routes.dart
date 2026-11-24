import 'package:flutter/material.dart';

import '../../commercial/data/commercial_remote_datasource.dart';
import '../../commercial/data/product_interest_auth_service.dart';
import '../../commercial/data/product_favorites_repository_impl.dart';
import '../../commercial/data/product_notifications_repository_impl.dart';
import '../../commercial/data/product_preferences_repository_impl.dart';
import '../../commercial/presentation/product_preferences_screen.dart';
import '../../commercial/presentation/product_notifications_screen.dart';
import '../../commercial/domain/commercial_repository.dart';
import '../../commercial/domain/product.dart';
import '../../commercial/presentation/catalog_screen.dart';
import '../../commercial/presentation/product_detail_screen.dart';
import '../../commercial/presentation/product_interest_screen.dart';
import '../../features/community/presentation/screens/product_reviews_screen.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

export '../../features/community/presentation/screens/product_reviews_screen.dart'
    show CommunityScreenArgs;

/// Named route constants for the application and its bounded contexts.
abstract final class AppRoutes {
  static const String home = '/';
  static const String commercial = '/commercial';
  static const String productDetail = '/commercial/product-detail';
  static const String productInterest = '/commercial/product-interest';
  static const String productNotifications = '/commercial/product-notifications';
  static const String productPreferences = '/commercial/product-preferences';
  static const String community = '/community';
}

/// Strongly-typed route arguments for navigating to [ProductDetailScreen].
final class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({required this.productId, this.initialProduct});

  final int productId;
  final Product? initialProduct;
}

/// Centralized route generator decoupling navigation logic from `app.dart`.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required CommercialRepository commercialRepository,
    DioClient? dioClient,
    SecureStorage? secureStorage,
  }) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const TerraTechHomeShell(),
      ),
      AppRoutes.commercial => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CatalogScreen(
          repository: commercialRepository,
          favoritesRepository: dioClient == null
              ? null
              : ProductFavoritesRepositoryImpl(dioClient: dioClient),
          canShowNotifications: dioClient != null,
        ),
      ),
      AppRoutes.productPreferences => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => dioClient == null
            ? const AppShellPlaceholder(title: 'Preferencias no disponibles')
            : ProductPreferencesScreen(
                repository: ProductPreferencesRepositoryImpl(dioClient: dioClient),
              ),
      ),
      AppRoutes.productNotifications => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => dioClient == null
            ? const AppShellPlaceholder(title: 'Notificaciones no disponibles')
            : ProductNotificationsScreen(
                repository: ProductNotificationsRepositoryImpl(dioClient: dioClient),
              ),
      ),
      AppRoutes.productDetail => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) {
          final args = settings.arguments;
          final productId = switch (args) {
            final ProductDetailRouteArgs a => a.productId,
            final Product p => p.id,
            final int id => id,
            _ => 1,
          };
          final initialProduct = switch (args) {
            final ProductDetailRouteArgs a => a.initialProduct,
            final Product p => p,
            _ => null,
          };
          return ProductDetailScreen(
            productId: productId,
            initialProduct: initialProduct,
            repository: commercialRepository,
            favoritesRepository: dioClient == null
                ? null
                : ProductFavoritesRepositoryImpl(dioClient: dioClient),
          );
        },
      ),
      AppRoutes.productInterest => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => dioClient != null && secureStorage != null
            ? ProductInterestScreen(
                repository: commercialRepository,
                authService: ProductInterestAuthService(
                  dioClient: dioClient,
                  secureStorage: secureStorage,
                ),
              )
            : const AppShellPlaceholder(
                title: 'Inicio de sesión no disponible',
              ),
      ),
      AppRoutes.community => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) {
          final args = settings.arguments;
          if (args is CommunityScreenArgs) {
            return ProductReviewsScreen(
              productId: args.productId,
              targetProfileId: args.targetProfileId,
              currentUserId: args.currentUserId,
              productOwnerUserId: args.productOwnerUserId,
              productName: args.productName,
              dioClient: dioClient,
            );
          }
          if (args is Map<String, dynamic>) {
            return ProductReviewsScreen(
              productId: (args['productId'] as num?)?.toInt() ?? 1,
              targetProfileId: (args['targetProfileId'] as num?)?.toInt() ?? 1,
              currentUserId:
                  (args['currentUserId'] as num?)?.toInt() ??
                  MockAuthSession.testUserId,
              productOwnerUserId: (args['productOwnerUserId'] as num?)?.toInt(),
              productName: args['productName'] as String?,
              dioClient: dioClient,
            );
          }
          return ProductReviewsScreen(
            productId: 1,
            targetProfileId: 1,
            currentUserId: MockAuthSession.testUserId,
            dioClient: dioClient,
          );
        },
      ),
      _ => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const AppShellPlaceholder(title: 'Not Found'),
      ),
    };
  }
}

/// Main landing hub providing navigation to the Commercial and Community
/// bounded contexts.
class TerraTechHomeShell extends StatelessWidget {
  const TerraTechHomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: const Text('TerraTech Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(
                        Icons.eco_rounded,
                        color: colorScheme.onPrimary,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Plataforma Agroecológica TerraTech',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Sesión activa: ${MockAuthSession.testUserFullName} (${MockAuthSession.testUserEmail})',
                    style: const TextStyle(
                      color: AppColors.whiteHigh,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Módulos Disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              button: true,
              label: 'Ir al catálogo de productos y trazabilidad',
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: InkWell(
                  key: const Key('home_navigate_commercial_card'),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.commercial);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: <Widget>[
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            size: 30,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Catálogo de Productos y Trazabilidad',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Consulta productos agrícolas por categoría, región de origen, prácticas de cultivo y trazabilidad IoT verificada.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              button: true,
              label: 'Ir a alertas de interés de productos',
              child: Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: ListTile(
                  key: const Key('home_navigate_product_interest_card'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryContainer,
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.onPrimaryContainer,
                    ),
                  ),
                  title: const Text(
                    'Alertas de interés de productos',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Consulta estadísticas y configura el umbral de tus productos.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.productInterest);
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Semantics(
              button: true,
              label: 'Ir a comunidad agrícola y reseñas de productores',
              child: Card(
                elevation: 0,
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  side: const BorderSide(color: AppColors.borderSubtle),
                ),
                child: ListTile(
                  key: const Key('home_navigate_community_card'),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.secondaryContainer,
                    child: Icon(
                      Icons.groups_rounded,
                      color: AppColors.onSecondaryContainer,
                    ),
                  ),
                  title: const Text(
                    'Comunidad Agrícola',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Perfiles públicos y reseñas de productores',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.secondary,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(AppRoutes.community);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder screen for bounded contexts pending implementation.
class AppShellPlaceholder extends StatelessWidget {
  const AppShellPlaceholder({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
