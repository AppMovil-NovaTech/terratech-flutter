import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../models/comment_model.dart';
import '../models/product_rating_summary_model.dart';

/// Contract for remote operations against the Community & Reviews backend endpoints.
abstract class ProductReviewsRemoteDataSource {
  Future<ProductRatingSummaryModel> getRatingSummary(int productId);

  Future<List<CommentModel>> getComments(int productId, {int? rating});

  Future<CommentModel> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  });

  Future<CommentModel> updateReview(
    int commentId, {
    required String content,
    required int rating,
  });

  Future<void> deleteReview(int commentId);
}

/// Implementation of [ProductReviewsRemoteDataSource] consuming [DioClient].
class ProductReviewsRemoteDataSourceImpl
    implements ProductReviewsRemoteDataSource {
  ProductReviewsRemoteDataSourceImpl({required this.dioClient});

  final DioClient dioClient;

  Dio get _dio => dioClient.dio;

  @override
  Future<ProductRatingSummaryModel> getRatingSummary(int productId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/products/$productId/ratings-summary',
    );
    final data = response.data ?? <String, dynamic>{};
    return ProductRatingSummaryModel.fromJson(data);
  }

  @override
  Future<List<CommentModel>> getComments(int productId, {int? rating}) async {
    final queryParams = <String, dynamic>{};
    if (rating != null) {
      queryParams['rating'] = rating;
    }

    final response = await _dio.get<dynamic>(
      '/api/v1/products/$productId/comments',
      queryParameters: queryParams,
    );
    final rawData = response.data;
    if (rawData is List<dynamic>) {
      return rawData
          .whereType<Map<String, dynamic>>()
          .map(CommentModel.fromJson)
          .toList();
    }
    return <CommentModel>[];
  }

  @override
  Future<CommentModel> createReview({
    required int userId,
    required int productId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/comments',
      data: <String, dynamic>{
        'userId': userId,
        'productId': productId,
        'targetProfileId': targetProfileId,
        'content': content,
        'rating': rating,
      },
    );
    final data = response.data ?? <String, dynamic>{};
    return CommentModel.fromJson(data);
  }

  @override
  Future<CommentModel> updateReview(
    int commentId, {
    required String content,
    required int rating,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/api/v1/comments/$commentId',
      data: <String, dynamic>{'content': content, 'rating': rating},
    );
    final data = response.data ?? <String, dynamic>{};
    return CommentModel.fromJson(data);
  }

  @override
  Future<void> deleteReview(int commentId) async {
    await _dio.delete<void>('/api/v1/comments/$commentId');
  }
}
