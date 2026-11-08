import '../repositories/product_reviews_repository.dart';

/// Use case to delete a review authored by the current user (US35 Scenario 3).
class DeleteProductReviewUseCase {
  const DeleteProductReviewUseCase(this._repository);

  final ProductReviewsRepository _repository;

  Future<void> call(int commentId) {
    return _repository.deleteReview(commentId);
  }
}
