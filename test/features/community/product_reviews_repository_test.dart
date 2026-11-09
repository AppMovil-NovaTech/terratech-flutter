import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/features/community/data/datasources/product_reviews_remote_data_source.dart';
import 'package:terratech_mobile/features/community/data/models/comment_model.dart';
import 'package:terratech_mobile/features/community/data/models/product_rating_summary_model.dart';
import 'package:terratech_mobile/features/community/data/models/rating_breakdown_model.dart';
import 'package:terratech_mobile/features/community/data/repositories/product_reviews_repository_impl.dart';
import 'package:terratech_mobile/features/community/domain/entities/product_rating_summary.dart';

class _FakeProductReviewsRemoteDataSource
    implements ProductReviewsRemoteDataSource {
  ProductRatingSummaryModel summary = const ProductRatingSummaryModel(
    productId: 104,
    averageRating: 4.2,
    totalReviews: 5,
    ratingBreakdown: RatingBreakdownModel(
      fiveStars: 3,
      fourStars: 1,
      threeStars: 0,
      twoStars: 0,
      oneStar: 1,
    ),
  );

  final List<CommentModel> comments = [
    CommentModel(
      id: 1,
      userId: 5,
      productId: 104,
      targetProfileId: 2,
      content: 'Excelente fertilizante orgánico, alta calidad.',
      rating: 5,
      createdAt: DateTime.parse('2026-11-08T18:30:00Z'),
      authorName: 'Carlos Mendoza',
    ),
    CommentModel(
      id: 2,
      userId: 12,
      productId: 104,
      targetProfileId: 2,
      content: 'Buen producto en general, tardó un poco el envío.',
      rating: 4,
      createdAt: DateTime.parse('2026-11-07T14:15:00Z'),
      authorName: 'María Quispe',
    ),
  ];

  @override
  Future<ProductRatingSummaryModel> getRatingSummary(int productId) async {
    return summary;
  }

  @override
  Future<List<CommentModel>> getComments(int productId, {int? rating}) async {
    if (rating != null) {
      return comments.where((c) => c.rating == rating).toList();
    }
    return comments;
  }

  @override
  Future<CommentModel> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) async {
    final newComment = CommentModel(
      id: comments.length + 1,
      userId: userId,
      productId: productId,
      targetProfileId: targetProfileId,
      content: content,
      rating: rating,
      createdAt: DateTime.now(),
      authorName: 'Usuario Actual',
    );
    comments.insert(0, newComment);
    return newComment;
  }

  @override
  Future<CommentModel> updateReview(
    int commentId, {
    required String content,
    required int rating,
  }) async {
    final index = comments.indexWhere((c) => c.id == commentId);
    final updated = CommentModel(
      id: commentId,
      userId: comments[index].userId,
      productId: comments[index].productId,
      targetProfileId: comments[index].targetProfileId,
      content: content,
      rating: rating,
      createdAt: comments[index].createdAt,
      authorName: comments[index].authorName,
    );
    comments[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteReview(int commentId) async {
    comments.removeWhere((c) => c.id == commentId);
  }
}

void main() {
  group('ProductReviewsRepository & Models Unit Tests', () {
    late _FakeProductReviewsRemoteDataSource fakeDataSource;
    late ProductReviewsRepositoryImpl repository;

    setUp(() {
      fakeDataSource = _FakeProductReviewsRemoteDataSource();
      repository = ProductReviewsRepositoryImpl(
        remoteDataSource: fakeDataSource,
      );
    });

    test('ProductRatingSummaryModel deserializes backend JSON accurately', () {
      final json = <String, dynamic>{
        'productId': 104,
        'averageRating': 3.6,
        'totalReviews': 5,
        'ratingBreakdown': {
          'oneStar': 1,
          'twoStars': 0,
          'threeStars': 1,
          'fourStars': 1,
          'fiveStars': 2,
        },
      };

      final model = ProductRatingSummaryModel.fromJson(json);

      expect(model.productId, 104);
      expect(model.averageRating, 3.6);
      expect(model.totalReviews, 5);
      expect(model.ratingBreakdown.fiveStars, 2);
      expect(model.ratingBreakdown.fourStars, 1);
      expect(model.ratingBreakdown.threeStars, 1);
      expect(model.ratingBreakdown.twoStars, 0);
      expect(model.ratingBreakdown.oneStar, 1);
      expect(model.hasLowReputationAlert, isFalse);
    });

    test('ProductRatingSummary flags low reputation when rating < 3.0 and reviews > 0', () {
      const summary = ProductRatingSummary(
        productId: 104,
        averageRating: 2.8,
        totalReviews: 3,
      );

      expect(summary.hasLowReputationAlert, isTrue);
    });

    test('CommentModel deserializes backend JSON with null safety', () {
      final json = <String, dynamic>{
        'id': 42,
        'userId': 5,
        'productId': 104,
        'targetProfileId': 2,
        'content': 'Muy buen fertilizante para el cultivo de maíz.',
        'rating': 5,
        'createdAt': '2026-11-08T18:30:00Z',
        'authorName': 'Carlos Mendoza',
      };

      final comment = CommentModel.fromJson(json);

      expect(comment.id, 42);
      expect(comment.userId, 5);
      expect(comment.productId, 104);
      expect(comment.targetProfileId, 2);
      expect(comment.content, 'Muy buen fertilizante para el cultivo de maíz.');
      expect(comment.rating, 5);
      expect(comment.authorName, 'Carlos Mendoza');
    });

    test('Repository retrieves rating summary correctly', () async {
      final summary = await repository.getRatingSummary(104);

      expect(summary.productId, 104);
      expect(summary.averageRating, 4.2);
      expect(summary.totalReviews, 5);
    });

    test('Repository retrieves all comments and filtered comments', () async {
      final allComments = await repository.getComments(104);
      expect(allComments.length, 2);

      final fiveStarComments = await repository.getComments(104, rating: 5);
      expect(fiveStarComments.length, 1);
      expect(fiveStarComments.first.rating, 5);
    });

    test('Repository creates, updates, and deletes reviews', () async {
      final created = await repository.createReview(
        userId: 7,
        productId: 104,
        targetProfileId: 2,
        content: 'Nuevo comentario de prueba de 10 caracteres',
        rating: 5,
      );
      expect(created.id, 3);
      expect(created.content, 'Nuevo comentario de prueba de 10 caracteres');

      final updated = await repository.updateReview(
        created.id,
        content: 'Comentario modificado con mas de diez caracteres',
        rating: 4,
      );
      expect(updated.rating, 4);
      expect(updated.content, 'Comentario modificado con mas de diez caracteres');

      await repository.deleteReview(created.id);
      final remaining = await repository.getComments(104);
      expect(remaining.any((c) => c.id == created.id), isFalse);
    });
  });
}
