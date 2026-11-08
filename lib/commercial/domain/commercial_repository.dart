import 'product.dart';
import 'traceability.dart';

/// Domain repository contract for the Commercial bounded context (US39 & US40).
///
/// Decouples presentation state management (BLoCs) from HTTP data sources and
/// DTO serialization details.
abstract interface class CommercialRepository {
  /// Retrieves the agricultural product catalog, optionally filtered by
  /// [category], [region], and partial or full [searchQuery] match on name.
  Future<List<Product>> getProducts({
    String? category,
    String? region,
    String? searchQuery,
  });

  /// Retrieves the complete detail, cultivation practices, and authorized
  /// traceability of a single product by its [id].
  Future<Product> getProductById(int id);

  /// Queries the registered and authorized TerraTech traceability record for
  /// a product by its [productId] (supports catalog or QR code lookup).
  Future<TraceabilityInfo> getProductTraceability(int productId);

  /// Initiates contact with the farmer of [product] utilizing the active
  /// user session context (US40 - Scenario 3).
  Future<FarmerContactResult> contactFarmer({
    required Product product,
    required String message,
  });
}
