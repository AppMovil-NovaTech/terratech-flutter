import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/problem_details.dart';
import '../data/commercial_repository_impl.dart';
import '../domain/commercial_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

/// BLoC managing the Product Catalog state, simultaneous category + region
/// filtering, and real-time name search (US39 - Scenarios 1, 2, and 3).
class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  CatalogBloc({required this.repository}) : super(const CatalogState()) {
    on<LoadCatalogRequested>(_onLoadCatalogRequested);
    on<CatalogCategoryFilterChanged>(_onCategoryFilterChanged);
    on<CatalogRegionFilterChanged>(_onRegionFilterChanged);
    on<CatalogFiltersApplied>(_onFiltersApplied);
    on<CatalogSearchQueryChanged>(_onSearchQueryChanged);
    on<CatalogFiltersCleared>(_onFiltersCleared);
  }

  final CommercialRepository repository;

  Future<void> _onLoadCatalogRequested(
    LoadCatalogRequested event,
    Emitter<CatalogState> emit,
  ) async {
    final activeCategory = event.preserveFilters ? state.selectedCategory : null;
    final activeRegion = event.preserveFilters ? state.selectedRegion : null;
    final activeSearch = event.preserveFilters ? state.searchQuery : '';

    emit(
      state.copyWith(
        status: CatalogStatus.loading,
        selectedCategory: () => activeCategory,
        selectedRegion: () => activeRegion,
        searchQuery: activeSearch,
        errorMessage: () => null,
        problemDetails: () => null,
      ),
    );

    try {
      final products = await repository.getProducts();
      final categories = _extractUniqueSorted(
        products.map((p) => p.category),
      );
      final regions = _extractUniqueSorted(
        products.map((p) => p.originRegion),
      );

      final filtered = CommercialRepositoryImpl.filterProducts(
        products: products,
        category: activeCategory,
        region: activeRegion,
        searchQuery: activeSearch,
      );

      emit(
        state.copyWith(
          status: CatalogStatus.success,
          allProducts: products,
          filteredProducts: filtered,
          availableCategories: categories,
          availableRegions: regions,
          errorMessage: () => null,
          problemDetails: () => null,
        ),
      );
    } on ProblemDetails catch (problem) {
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: () => problem.userMessage,
          problemDetails: () => problem,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: CatalogStatus.failure,
          errorMessage: () =>
              'No se pudo cargar el catálogo de productos: $error',
        ),
      );
    }
  }

  void _onCategoryFilterChanged(
    CatalogCategoryFilterChanged event,
    Emitter<CatalogState> emit,
  ) {
    final normalizedCategory = _cleanFilter(event.category);
    final filtered = CommercialRepositoryImpl.filterProducts(
      products: state.allProducts,
      category: normalizedCategory,
      region: state.selectedRegion,
      searchQuery: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedCategory: () => normalizedCategory,
        filteredProducts: filtered,
      ),
    );
  }

  void _onRegionFilterChanged(
    CatalogRegionFilterChanged event,
    Emitter<CatalogState> emit,
  ) {
    final normalizedRegion = _cleanFilter(event.region);
    final filtered = CommercialRepositoryImpl.filterProducts(
      products: state.allProducts,
      category: state.selectedCategory,
      region: normalizedRegion,
      searchQuery: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedRegion: () => normalizedRegion,
        filteredProducts: filtered,
      ),
    );
  }

  void _onFiltersApplied(
    CatalogFiltersApplied event,
    Emitter<CatalogState> emit,
  ) {
    final normalizedCategory = _cleanFilter(event.category);
    final normalizedRegion = _cleanFilter(event.region);
    final filtered = CommercialRepositoryImpl.filterProducts(
      products: state.allProducts,
      category: normalizedCategory,
      region: normalizedRegion,
      searchQuery: state.searchQuery,
    );

    emit(
      state.copyWith(
        selectedCategory: () => normalizedCategory,
        selectedRegion: () => normalizedRegion,
        filteredProducts: filtered,
      ),
    );
  }

  void _onSearchQueryChanged(
    CatalogSearchQueryChanged event,
    Emitter<CatalogState> emit,
  ) {
    final query = event.query;
    final filtered = CommercialRepositoryImpl.filterProducts(
      products: state.allProducts,
      category: state.selectedCategory,
      region: state.selectedRegion,
      searchQuery: query,
    );

    emit(
      state.copyWith(
        searchQuery: query,
        filteredProducts: filtered,
      ),
    );
  }

  void _onFiltersCleared(
    CatalogFiltersCleared event,
    Emitter<CatalogState> emit,
  ) {
    emit(
      state.copyWith(
        selectedCategory: () => null,
        selectedRegion: () => null,
        searchQuery: '',
        filteredProducts: state.allProducts,
      ),
    );
  }

  static String? _cleanFilter(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'todas' ||
        trimmed.toLowerCase() == 'todos') {
      return null;
    }
    return trimmed;
  }

  static List<String> _extractUniqueSorted(Iterable<String> items) {
    final unique = <String>{};
    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isNotEmpty) {
        unique.add(trimmed);
      }
    }
    final list = unique.toList()..sort();
    return List<String>.unmodifiable(list);
  }
}
