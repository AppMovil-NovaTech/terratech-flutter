import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/problem_details.dart';
import '../../domain/usecases/create_product_review_usecase.dart';
import '../../domain/usecases/delete_product_review_usecase.dart';
import '../../domain/usecases/get_product_comments_usecase.dart';
import '../../domain/usecases/get_product_rating_summary_usecase.dart';
import '../../domain/usecases/update_product_review_usecase.dart';
import 'product_reviews_state.dart';

/// Controller managing business logic and UI state for product reviews and reputation.
class ProductReviewsController extends ChangeNotifier {
  ProductReviewsController({
    required int productId,
    required this.getProductRatingSummaryUseCase,
    required this.getProductCommentsUseCase,
    required this.createProductReviewUseCase,
    required this.updateProductReviewUseCase,
    required this.deleteProductReviewUseCase,
  }) : _state = ProductReviewsState(productId: productId);

  final GetProductRatingSummaryUseCase getProductRatingSummaryUseCase;
  final GetProductCommentsUseCase getProductCommentsUseCase;
  final CreateProductReviewUseCase createProductReviewUseCase;
  final UpdateProductReviewUseCase updateProductReviewUseCase;
  final DeleteProductReviewUseCase deleteProductReviewUseCase;

  ProductReviewsState _state;

  ProductReviewsState get state => _state;

  int get productId => _state.productId;

  /// Loads both the product reputation summary and the comments list.
  Future<void> load({bool reloadSummary = true}) async {
    _state = _state.copyWith(
      isLoading: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    notifyListeners();

    try {
      final summaryFuture = reloadSummary
          ? getProductRatingSummaryUseCase(_state.productId)
          : Future.value(_state.summary);

      final commentsFuture = getProductCommentsUseCase(
        _state.productId,
        rating: _state.selectedRatingFilter,
      );

      final results = await Future.wait([
        summaryFuture,
        commentsFuture,
      ]);

      _state = _state.copyWith(
        isLoading: false,
        summary: results[0] as dynamic,
        comments: (results[1] as List<dynamic>).cast(),
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    }

    notifyListeners();
  }

  /// Changes the star filter [1..5] (or null for all) and reloads comments.
  Future<void> setRatingFilter(int? rating) async {
    if (rating == null || _state.selectedRatingFilter == rating) {
      // Tapping "Todas" (null) or the currently selected filter returns to all
      _state = _state.copyWith(clearRatingFilter: true);
    } else {
      _state = _state.copyWith(selectedRatingFilter: rating);
    }
    notifyListeners();

    _state = _state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final comments = await getProductCommentsUseCase(
        _state.productId,
        rating: _state.selectedRatingFilter,
      );
      _state = _state.copyWith(
        isLoading: false,
        comments: comments,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: _extractErrorMessage(e),
      );
    }

    notifyListeners();
  }

  /// Publishes a new review for the current product (US35).
  Future<bool> createReview({
    required int userId,
    required int targetProfileId,
    required String content,
    required int rating,
  }) async {
    _state = _state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    notifyListeners();

    try {
      await createProductReviewUseCase(
        userId: userId,
        productId: _state.productId,
        targetProfileId: targetProfileId,
        content: content,
        rating: rating,
      );

      // Refresh both summary and comments to reflect the new rating
      final summary = await getProductRatingSummaryUseCase(_state.productId);
      final comments = await getProductCommentsUseCase(
        _state.productId,
        rating: _state.selectedRatingFilter,
      );

      _state = _state.copyWith(
        isSubmitting: false,
        summary: summary,
        comments: comments,
        successMessage: '¡Tu reseña ha sido publicada con éxito!',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: _extractErrorMessage(e),
      );
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing review (US35 Scenario 3).
  Future<bool> updateReview({
    required int commentId,
    required String content,
    required int rating,
  }) async {
    _state = _state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    notifyListeners();

    try {
      await updateProductReviewUseCase(
        commentId,
        content: content,
        rating: rating,
      );

      final summary = await getProductRatingSummaryUseCase(_state.productId);
      final comments = await getProductCommentsUseCase(
        _state.productId,
        rating: _state.selectedRatingFilter,
      );

      _state = _state.copyWith(
        isSubmitting: false,
        summary: summary,
        comments: comments,
        successMessage: 'Reseña actualizada correctamente.',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: _extractErrorMessage(e),
      );
      notifyListeners();
      return false;
    }
  }

  /// Deletes an existing review (US35 Scenario 3).
  Future<bool> deleteReview(int commentId) async {
    _state = _state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    notifyListeners();

    try {
      await deleteProductReviewUseCase(commentId);

      final summary = await getProductRatingSummaryUseCase(_state.productId);
      final comments = await getProductCommentsUseCase(
        _state.productId,
        rating: _state.selectedRatingFilter,
      );

      _state = _state.copyWith(
        isSubmitting: false,
        summary: summary,
        comments: comments,
        successMessage: 'La reseña fue eliminada con éxito.',
      );
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: _extractErrorMessage(e),
      );
      notifyListeners();
      return false;
    }
  }

  /// Clears any transient feedback messages (errors or success notices).
  void clearMessages() {
    _state = _state.copyWith(
      clearErrorMessage: true,
      clearSuccessMessage: true,
    );
    notifyListeners();
  }

  String _extractErrorMessage(Object error) {
    if (error is DioException && error.error is ProblemDetails) {
      return (error.error as ProblemDetails).userMessage;
    }
    if (error is ProblemDetails) {
      return error.userMessage;
    }
    if (error is ArgumentError) {
      return error.message?.toString() ?? 'Dato inválido.';
    }
    return error.toString();
  }
}
