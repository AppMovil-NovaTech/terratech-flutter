import 'product.dart';
import 'product_interest.dart';
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

  /// US29: registers one visit to a product detail screen.
  Future<void> registerProductConsultation(int productId);

  /// US29: owner-only product interest statistics.
  Future<ProductInterest> getProductInterest(int productId);

  /// US29: owner-only product interest threshold configuration.
  Future<ProductInterest> updateProductInterestThreshold(
    int productId,
    int threshold,
  );

  /// US29: owner-only on-demand inactivity check (not scheduled).
  Future<void> checkProductInactivity(int productId);

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
