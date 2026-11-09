import '../entities/comment.dart';
import '../entities/product_rating_summary.dart';

/// Repository interface governing product reviews and reputation operations.
abstract interface class ProductReviewsRepository {
  /// Fetches the aggregated rating summary and star breakdown for a given product.
  Future<ProductRatingSummary> getRatingSummary(int productId);

  /// Fetches reviews/comments for a product, optionally filtered by star rating [1..5].
  Future<List<Comment>> getComments(int productId, {int? rating});

  /// Publishes a new review/comment authored by the current authenticated user.
  Future<Comment> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  });

  /// Updates an existing review/comment authored by the current authenticated user.
  Future<Comment> updateReview(
    int commentId, {
    required String content,
    required int rating,
  });

  /// Deletes an existing review/comment authored by the current authenticated user.
  Future<void> deleteReview(int commentId);
}
