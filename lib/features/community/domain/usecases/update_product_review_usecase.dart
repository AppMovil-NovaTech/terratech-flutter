import '../entities/comment.dart';
import '../repositories/product_reviews_repository.dart';

/// Use case to validate and update an existing review (US35 Scenario 3).
class UpdateProductReviewUseCase {
  const UpdateProductReviewUseCase(this._repository);

  final ProductReviewsRepository _repository;

  static const int minContentLength = 10;
  static const int maxContentLength = 500;

  Future<Comment> call(
    int commentId, {
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

    return _repository.updateReview(
      commentId,
      content: trimmedContent,
      rating: rating,
    );
  }
}
