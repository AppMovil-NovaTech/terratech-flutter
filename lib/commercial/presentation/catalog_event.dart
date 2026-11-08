import 'package:equatable/equatable.dart';

/// Base class for all events handled by `CatalogBloc` (US39).
sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Triggers loading or refreshing the product catalog from the backend.
final class LoadCatalogRequested extends CatalogEvent {
  const LoadCatalogRequested({this.preserveFilters = true});

  final bool preserveFilters;

  @override
  List<Object?> get props => <Object?>[preserveFilters];
}

/// Updates the active category filter (US39 - Scenario 2).
/// Passing `null` or empty string clears the category filter.
final class CatalogCategoryFilterChanged extends CatalogEvent {
  const CatalogCategoryFilterChanged(this.category);

  final String? category;

  @override
  List<Object?> get props => <Object?>[category];
}

/// Updates the active origin region filter (US39 - Scenario 2).
/// Passing `null` or empty string clears the region filter.
final class CatalogRegionFilterChanged extends CatalogEvent {
  const CatalogRegionFilterChanged(this.region);

  final String? region;

  @override
  List<Object?> get props => <Object?>[region];
}

/// Applies both category and region filters simultaneously (US39 - Scenario 2).
final class CatalogFiltersApplied extends CatalogEvent {
  const CatalogFiltersApplied({
    required this.category,
    required this.region,
  });

  final String? category;
  final String? region;

  @override
  List<Object?> get props => <Object?>[category, region];
}

/// Updates the real-time product name search query (US39 - Scenario 3).
final class CatalogSearchQueryChanged extends CatalogEvent {
  const CatalogSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

/// Clears all active category, region, and search filters.
final class CatalogFiltersCleared extends CatalogEvent {
  const CatalogFiltersCleared();
}
