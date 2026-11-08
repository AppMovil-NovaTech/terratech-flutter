import 'package:equatable/equatable.dart';

import '../../core/errors/problem_details.dart';
import '../domain/product.dart';

/// Enumeration of loading statuses for the product catalog (US39).
enum CatalogStatus {
  initial,
  loading,
  success,
  failure,
}

/// Immutable state managed by `CatalogBloc` for US39.
final class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.allProducts = const <Product>[],
    this.filteredProducts = const <Product>[],
    this.availableCategories = const <String>[],
    this.availableRegions = const <String>[],
    this.selectedCategory,
    this.selectedRegion,
    this.searchQuery = '',
    this.errorMessage,
    this.problemDetails,
  });

  final CatalogStatus status;
  final List<Product> allProducts;
  final List<Product> filteredProducts;
  final List<String> availableCategories;
  final List<String> availableRegions;
  final String? selectedCategory;
  final String? selectedRegion;
  final String searchQuery;
  final String? errorMessage;
  final ProblemDetails? problemDetails;

  /// Whether any category, region, or search filter is currently active.
  bool get hasActiveFilters =>
      (selectedCategory != null && selectedCategory!.trim().isNotEmpty) ||
      (selectedRegion != null && selectedRegion!.trim().isNotEmpty) ||
      searchQuery.trim().isNotEmpty;

  /// Number of active dropdown/chip filters (category + region).
  int get activeFilterCount {
    int count = 0;
    if (selectedCategory != null && selectedCategory!.trim().isNotEmpty) {
      count++;
    }
    if (selectedRegion != null && selectedRegion!.trim().isNotEmpty) {
      count++;
    }
    return count;
  }

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? allProducts,
    List<Product>? filteredProducts,
    List<String>? availableCategories,
    List<String>? availableRegions,
    String? Function()? selectedCategory,
    String? Function()? selectedRegion,
    String? searchQuery,
    String? Function()? errorMessage,
    ProblemDetails? Function()? problemDetails,
  }) {
    return CatalogState(
      status: status ?? this.status,
      allProducts: allProducts ?? this.allProducts,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      availableCategories: availableCategories ?? this.availableCategories,
      availableRegions: availableRegions ?? this.availableRegions,
      selectedCategory: selectedCategory != null
          ? selectedCategory()
          : this.selectedCategory,
      selectedRegion: selectedRegion != null
          ? selectedRegion()
          : this.selectedRegion,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      problemDetails: problemDetails != null
          ? problemDetails()
          : this.problemDetails,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    allProducts,
    filteredProducts,
    availableCategories,
    availableRegions,
    selectedCategory,
    selectedRegion,
    searchQuery,
    errorMessage,
    problemDetails,
  ];
}
