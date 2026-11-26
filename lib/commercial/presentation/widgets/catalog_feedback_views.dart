import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Empty-state view displayed when no catalog products match the active
/// search or filter criteria.
class CatalogEmptyResultView extends StatelessWidget {
  const CatalogEmptyResultView({
    super.key,
    required this.hasActiveFilters,
    required this.onClearFilters,
  });

  final bool hasActiveFilters;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              hasActiveFilters
                  ? 'No se encontraron productos para los filtros seleccionados'
                  : 'El catálogo aún no tiene productos registrados',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              hasActiveFilters
                  ? 'Intenta ajustar la categoría, la región de origen o el término de búsqueda.'
                  : 'Cuando los agricultores registren lotes en TerraTech aparecerán aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (hasActiveFilters) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonalIcon(
                key: const Key('empty_state_clear_filters_button'),
                onPressed: onClearFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Mostrar todos los productos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error-state view displayed when the catalog request fails with an RFC 7807
/// `ProblemDetails` or network exception.
class CatalogErrorView extends StatelessWidget {
  const CatalogErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.cloud_off_rounded,
              size: 54,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error al cargar el catálogo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              key: const Key('catalog_retry_button'),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar conexión'),
            ),
          ],
        ),
      ),
    );
  }
}
