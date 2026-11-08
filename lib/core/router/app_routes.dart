import 'package:flutter/material.dart';

import '../../commercial/data/commercial_remote_datasource.dart';
import '../../commercial/domain/commercial_repository.dart';
import '../../commercial/domain/product.dart';
import '../../commercial/presentation/catalog_screen.dart';
import '../../commercial/presentation/product_detail_screen.dart';

/// Named route constants for the application and its bounded contexts.
abstract final class AppRoutes {
  static const String home = '/';
  static const String commercial = '/commercial';
  static const String productDetail = '/commercial/product-detail';
  static const String community = '/community';
}

/// Strongly-typed route arguments for navigating to [ProductDetailScreen].
final class ProductDetailRouteArgs {
  const ProductDetailRouteArgs({
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final Product? initialProduct;
}

/// Centralized route generator decoupling navigation logic from `app.dart`.
abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    required CommercialRepository commercialRepository,
  }) {
    return switch (settings.name) {
      AppRoutes.home => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const TerraTechHomeShell(),
      ),
      AppRoutes.commercial => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CatalogScreen(repository: commercialRepository),
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
          );
        },
      ),
      AppRoutes.community => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const AppShellPlaceholder(title: 'Community Module'),
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
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    colorScheme.primary,
                    colorScheme.primaryContainer,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
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
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 8),
                  Text(
                    'Sesión activa: ${MockAuthSession.testUserFullName} (${MockAuthSession.testUserEmail})',
                    style: TextStyle(
                      color: colorScheme.onPrimary.withValues(alpha: 0.92),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Módulos Disponibles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: InkWell(
                key: const Key('home_navigate_commercial_card'),
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.commercial);
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 30,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Catálogo de Productos y Trazabilidad',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Consulta productos agrícolas por categoría, región de origen, prácticas de cultivo y trazabilidad IoT verificada.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerLow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: colorScheme.secondaryContainer,
                  child: Icon(
                    Icons.groups_rounded,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text(
                  'Comunidad Agrícola',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: const Text(
                  'Perfiles públicos y reseñas de productores',
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.of(context).pushNamed(AppRoutes.community);
                },
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
  const AppShellPlaceholder({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
