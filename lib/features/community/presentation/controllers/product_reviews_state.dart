import '../../domain/entities/comment.dart';
import '../../domain/entities/product_rating_summary.dart';

/// State representation for the Product Reviews and Reputation screen.
class ProductReviewsState {
  const ProductReviewsState({
    required this.productId,
    this.summary,
    this.comments = const <Comment>[],
    this.selectedRatingFilter,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.successMessage,
  });

  final int productId;
  final ProductRatingSummary? summary;
  final List<Comment> comments;
  final int? selectedRatingFilter;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final String? successMessage;

  ProductReviewsState copyWith({
    int? productId,
    ProductRatingSummary? summary,
    List<Comment>? comments,
    int? selectedRatingFilter,
    bool clearRatingFilter = false,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return ProductReviewsState(
      productId: productId ?? this.productId,
      summary: summary ?? this.summary,
      comments: comments ?? this.comments,
      selectedRatingFilter: clearRatingFilter
          ? null
          : (selectedRatingFilter ?? this.selectedRatingFilter),
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductReviewsState &&
        other.productId == productId &&
        other.summary == summary &&
        other.selectedRatingFilter == selectedRatingFilter &&
        other.isLoading == isLoading &&
        other.isSubmitting == isSubmitting &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage &&
        _listEquals(other.comments, comments);
  }

  static bool _listEquals(List<Comment> a, List<Comment> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(
    productId,
    summary,
    selectedRatingFilter,
    isLoading,
    isSubmitting,
    errorMessage,
    successMessage,
    Object.hashAll(comments),
  );

  @override
  String toString() {
    return 'ProductReviewsState(productId: $productId, totalComments: ${comments.length}, filter: $selectedRatingFilter, loading: $isLoading, submitting: $isSubmitting)';
  }
}
