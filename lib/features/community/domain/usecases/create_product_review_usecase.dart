import '../entities/comment.dart';
import '../repositories/product_reviews_repository.dart';

/// Use case to validate and publish a new product review (US35).
class CreateProductReviewUseCase {
  const CreateProductReviewUseCase(this._repository);

  final ProductReviewsRepository _repository;

  static const int minContentLength = 10;
  static const int maxContentLength = 500;

  Future<Comment> call({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) {
    final trimmedContent = content.trim();

    if (trimmedContent.length < minContentLength) {
      throw ArgumentError(
        'La reseña debe contener al menos 10 caracteres para ser publicada.',
      );
    }

    if (trimmedContent.length > maxContentLength) {
      throw ArgumentError(
        'La reseña no debe exceder los 500 caracteres.',
      );
    }

    if (rating < 1 || rating > 5) {
      throw ArgumentError('La calificación debe estar entre 1 y 5 estrellas.');
    }

    return _repository.createReview(
      userId: userId,
      productId: productId,
      targetProfileId: targetProfileId,
      content: trimmedContent,
      rating: rating,
    );
  }
}
