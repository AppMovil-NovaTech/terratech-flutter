import '../domain/commercial_repository.dart';
import '../domain/product.dart';
import '../domain/traceability.dart';
import 'commercial_remote_datasource.dart';

/// Concrete implementation of [CommercialRepository] delegating network
/// calls to [CommercialRemoteDataSource].
class CommercialRepositoryImpl implements CommercialRepository {
  const CommercialRepositoryImpl({required this.remoteDataSource});

  final CommercialRemoteDataSource remoteDataSource;

  @override
  Future<List<Product>> getProducts({
    String? category,
    String? region,
    String? searchQuery,
  }) async {
    final models = await remoteDataSource.getProducts();
    return filterProducts(
      products: models,
      category: category,
      region: region,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<Product> getProductById(int id) {
    return remoteDataSource.getProductById(id);
  }

  @override
  Future<TraceabilityInfo> getProductTraceability(int productId) {
    return remoteDataSource.getProductTraceability(productId);
  }

  @override
  Future<FarmerContactResult> contactFarmer({
    required Product product,
    required String message,
  }) {
    return remoteDataSource.contactFarmer(
      product: product,
      message: message,
    );
  }

  /// Applies simultaneous category, origin region, and partial/total name search
  /// filtering over [products] (US39 - Scenarios 2 & 3).
  static List<Product> filterProducts({
    required List<Product> products,
    String? category,
    String? region,
    String? searchQuery,
  }) {
    final normalizedCategory = _normalizeFilterValue(category);
    final normalizedRegion = _normalizeFilterValue(region);
    final normalizedSearch = _normalizeText(searchQuery ?? '');

    return products.where((product) {
      final matchesCategory =
          normalizedCategory == null ||
          _normalizeText(product.category) == normalizedCategory;

      final matchesRegion =
          normalizedRegion == null ||
          _normalizeText(product.originRegion) == normalizedRegion;

      final matchesSearch =
          normalizedSearch.isEmpty ||
          _normalizeText(product.name).contains(normalizedSearch);

      return matchesCategory && matchesRegion && matchesSearch;
    }).toList(growable: false);
  }

  static String? _normalizeFilterValue(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.toLowerCase() == 'todas' ||
        trimmed.toLowerCase() == 'todos' ||
        trimmed.toLowerCase() == 'all') {
      return null;
    }
    return _normalizeText(trimmed);
  }

  /// Normalizes strings to lowercase and strips Spanish diacritics so searches
  /// like "cafe" match "Café" and "junin" matches "Junín".
  static String _normalizeText(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u');
  }
}
