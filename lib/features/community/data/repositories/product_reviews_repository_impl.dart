import '../../domain/entities/comment.dart';
import '../../domain/entities/product_rating_summary.dart';
import '../../domain/repositories/product_reviews_repository.dart';
import '../datasources/product_reviews_remote_data_source.dart';

/// Implementation of [ProductReviewsRepository] delegating to [ProductReviewsRemoteDataSource].
class ProductReviewsRepositoryImpl implements ProductReviewsRepository {
  const ProductReviewsRepositoryImpl({
    required this.remoteDataSource,
  });

  final ProductReviewsRemoteDataSource remoteDataSource;

  @override
  Future<ProductRatingSummary> getRatingSummary(int productId) {
    return remoteDataSource.getRatingSummary(productId);
  }

  @override
  Future<List<Comment>> getComments(int productId, {int? rating}) async {
    final comments = await remoteDataSource.getComments(
      productId,
      rating: rating,
    );
    return comments;
  }

  @override
  Future<Comment> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) {
    return remoteDataSource.createReview(
      userId: userId,
      productId: productId,
      targetProfileId: targetProfileId,
      content: content,
      rating: rating,
    );
  }

  @override
  Future<Comment> updateReview(
    int commentId, {
    required String content,
    required int rating,
  }) {
    return remoteDataSource.updateReview(
      commentId,
      content: content,
      rating: rating,
    );
  }

  @override
  Future<void> deleteReview(int commentId) {
    return remoteDataSource.deleteReview(commentId);
  }
}
