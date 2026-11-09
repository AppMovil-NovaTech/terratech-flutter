import '../entities/product_rating_summary.dart';
import '../repositories/product_reviews_repository.dart';

/// Use case to retrieve the rating summary and star distribution for a product.
class GetProductRatingSummaryUseCase {
  const GetProductRatingSummaryUseCase(this._repository);

  final ProductReviewsRepository _repository;

  Future<ProductRatingSummary> call(int productId) {
    return _repository.getRatingSummary(productId);
  }
}
