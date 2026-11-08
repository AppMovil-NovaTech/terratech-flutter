import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/features/community/domain/entities/comment.dart';
import 'package:terratech_mobile/features/community/domain/entities/product_rating_summary.dart';
import 'package:terratech_mobile/features/community/domain/entities/rating_breakdown.dart';
import 'package:terratech_mobile/features/community/domain/repositories/product_reviews_repository.dart';
import 'package:terratech_mobile/features/community/domain/usecases/create_product_review_usecase.dart';
import 'package:terratech_mobile/features/community/domain/usecases/delete_product_review_usecase.dart';
import 'package:terratech_mobile/features/community/domain/usecases/get_product_comments_usecase.dart';
import 'package:terratech_mobile/features/community/domain/usecases/get_product_rating_summary_usecase.dart';
import 'package:terratech_mobile/features/community/domain/usecases/update_product_review_usecase.dart';
import 'package:terratech_mobile/features/community/presentation/controllers/product_reviews_controller.dart';

class _FakeProductReviewsRepository implements ProductReviewsRepository {
  ProductRatingSummary summary = const ProductRatingSummary(
    productId: 104,
    averageRating: 4.0,
    totalReviews: 2,
    ratingBreakdown: RatingBreakdown(fiveStars: 1, threeStars: 1),
  );

  final List<Comment> comments = [
    Comment(
      id: 1,
      userId: 5,
      productId: 104,
      targetProfileId: 2,
      content: 'Comentario original con más de diez caracteres.',
      rating: 5,
      createdAt: DateTime.now(),
      authorName: 'Carlos M.',
    ),
  ];

  bool shouldThrowOnCreate = false;

  @override
  Future<ProductRatingSummary> getRatingSummary(int productId) async => summary;

  @override
  Future<List<Comment>> getComments(int productId, {int? rating}) async {
    if (rating != null) {
      return comments.where((c) => c.rating == rating).toList();
    }
    return comments;
  }

  @override
  Future<Comment> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) async {
    if (shouldThrowOnCreate) {
      throw Exception('Error al conectar con el servidor.');
    }
    final comment = Comment(
      id: comments.length + 1,
      userId: userId,
      productId: productId,
      targetProfileId: targetProfileId,
      content: content,
      rating: rating,
      createdAt: DateTime.now(),
      authorName: 'Usuario Autenticado',
    );
    comments.insert(0, comment);
    return comment;
  }

  @override
  Future<Comment> updateReview(
    int commentId, {
    required String content,
    required int rating,
  }) async {
    final idx = comments.indexWhere((c) => c.id == commentId);
    final updated = comments[idx].copyWith(content: content, rating: rating);
    comments[idx] = updated;
    return updated;
  }

  @override
  Future<void> deleteReview(int commentId) async {
    comments.removeWhere((c) => c.id == commentId);
  }
}

void main() {
  group('ProductReviewsController Unit Tests', () {
    late _FakeProductReviewsRepository repository;
    late ProductReviewsController controller;

    setUp(() {
      repository = _FakeProductReviewsRepository();
      controller = ProductReviewsController(
        productId: 104,
        getProductRatingSummaryUseCase: GetProductRatingSummaryUseCase(repository),
        getProductCommentsUseCase: GetProductCommentsUseCase(repository),
        createProductReviewUseCase: CreateProductReviewUseCase(repository),
        updateProductReviewUseCase: UpdateProductReviewUseCase(repository),
        deleteProductReviewUseCase: DeleteProductReviewUseCase(repository),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('Initial state is clean with specified productId', () {
      expect(controller.productId, 104);
      expect(controller.state.summary, isNull);
      expect(controller.state.comments, isEmpty);
      expect(controller.state.isLoading, isFalse);
    });

    test('load() populates summary and comments', () async {
      await controller.load();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.summary?.averageRating, 4.0);
      expect(controller.state.comments.length, 1);
    });

    test('setRatingFilter() filters comments and toggling unselects', () async {
      await controller.load();
      expect(controller.state.comments.length, 1);

      // Filter by 1 star (no reviews exist for 1 star)
      await controller.setRatingFilter(1);
      expect(controller.state.selectedRatingFilter, 1);
      expect(controller.state.comments, isEmpty);

      // Tapping 1 star again should remove the filter and show all
      await controller.setRatingFilter(1);
      expect(controller.state.selectedRatingFilter, isNull);
      expect(controller.state.comments.length, 1);
    });

    test('createReview() rejects content under 10 chars at domain level', () async {
      final success = await controller.createReview(
        userId: 5,
        targetProfileId: 2,
        content: 'Corto',
        rating: 5,
      );

      expect(success, isFalse);
      expect(
        controller.state.errorMessage,
        contains('al menos 10 caracteres'),
      );
    });

    test('createReview() successfully posts review and updates success message', () async {
      final success = await controller.createReview(
        userId: 5,
        targetProfileId: 2,
        content: 'Excelente fertilizante para café y cacao.',
        rating: 5,
      );

      expect(success, isTrue);
      expect(controller.state.successMessage, isNotNull);
      expect(controller.state.comments.length, 2);
    });

    test('createReview() sets error message on server failure', () async {
      repository.shouldThrowOnCreate = true;

      final success = await controller.createReview(
        userId: 5,
        targetProfileId: 2,
        content: 'Reseña válida con más de diez caracteres.',
        rating: 4,
      );

      expect(success, isFalse);
      expect(controller.state.errorMessage, isNotNull);
    });

    test('updateReview() modifies comment and sets success message', () async {
      await controller.load();

      final success = await controller.updateReview(
        commentId: 1,
        content: 'Texto modificado con suficientes caracteres.',
        rating: 4,
      );

      expect(success, isTrue);
      expect(controller.state.successMessage, isNotNull);
      expect(controller.state.comments.first.rating, 4);
    });

    test('deleteReview() removes comment and updates state', () async {
      await controller.load();
      expect(controller.state.comments.length, 1);

      final success = await controller.deleteReview(1);

      expect(success, isTrue);
      expect(controller.state.comments, isEmpty);
    });

    test('clearMessages() cleans both error and success messages', () async {
      await controller.createReview(
        userId: 5,
        targetProfileId: 2,
        content: 'Excelente fertilizante con mas de diez caracteres',
        rating: 5,
      );
      expect(controller.state.successMessage, isNotNull);

      controller.clearMessages();
      expect(controller.state.successMessage, isNull);
      expect(controller.state.errorMessage, isNull);
    });
  });
}
