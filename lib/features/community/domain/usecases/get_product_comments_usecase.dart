import '../entities/comment.dart';
import '../repositories/product_reviews_repository.dart';

/// Use case to retrieve the comments/reviews for a product, optionally filtered by star rating.
class GetProductCommentsUseCase {
  const GetProductCommentsUseCase(this._repository);

  final ProductReviewsRepository _repository;

  Future<List<Comment>> call(int productId, {int? rating}) {
    if (rating != null && (rating < 1 || rating > 5)) {
      throw ArgumentError.value(
        rating,
        'rating',
        'El filtro de calificación debe estar entre 1 y 5 estrellas.',
      );
    }
    return _repository.getComments(productId, rating: rating);
  }
}
