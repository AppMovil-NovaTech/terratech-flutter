import 'package:flutter/material.dart';

import '../../../../core/network/dio_client.dart';
import '../../data/datasources/product_reviews_remote_data_source.dart';
import '../../data/repositories/product_reviews_repository_impl.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/create_product_review_usecase.dart';
import '../../domain/usecases/delete_product_review_usecase.dart';
import '../../domain/usecases/get_product_comments_usecase.dart';
import '../../domain/usecases/get_product_rating_summary_usecase.dart';
import '../../domain/usecases/update_product_review_usecase.dart';
import '../controllers/product_reviews_controller.dart';
import '../widgets/comment_list_item.dart';
import '../widgets/rating_filter_chips.dart';
import '../widgets/rating_summary_card.dart';
import '../widgets/review_input_bottom_sheet.dart';

/// Screen arguments model for navigating to [ProductReviewsScreen].
class CommunityScreenArgs {
  const CommunityScreenArgs({
    this.productId = 104,
    this.targetProfileId = 2,
    this.currentUserId = 5,
    this.productOwnerUserId,
  });

  final int productId;
  final int targetProfileId;
  final int? currentUserId;
  final int? productOwnerUserId;
}

/// Main presentation screen for Epic 11: Product Reviews, Ratings & Reputation (US33, US34, US35, US36).
class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({
    super.key,
    required this.productId,
    this.targetProfileId = 2,
    this.currentUserId = 5,
    this.productOwnerUserId,
    this.controller,
    this.dioClient,
  });

  final int productId;
  final int targetProfileId;
  final int? currentUserId;
  final int? productOwnerUserId;
  final ProductReviewsController? controller;
  final DioClient? dioClient;

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  late final ProductReviewsController _controller;
  late final bool _isInternalController;

  static const Color primaryGreen = Color(0xFF2E7D32);

  bool get _canWriteReview {
    if (widget.currentUserId == null) return false;
    // Anti Auto-Reseña (Section 6)
    if (widget.productOwnerUserId != null &&
        widget.currentUserId == widget.productOwnerUserId) {
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      final dioClient = widget.dioClient;
      if (dioClient == null) {
        throw StateError(
          'Either a ProductReviewsController or a DioClient must be provided to ProductReviewsScreen.',
        );
      }
      final remoteDataSource = ProductReviewsRemoteDataSourceImpl(
        dioClient: dioClient,
      );
      final repository = ProductReviewsRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
      _controller = ProductReviewsController(
        productId: widget.productId,
        getProductRatingSummaryUseCase: GetProductRatingSummaryUseCase(repository),
        getProductCommentsUseCase: GetProductCommentsUseCase(repository),
        createProductReviewUseCase: CreateProductReviewUseCase(repository),
        updateProductReviewUseCase: UpdateProductReviewUseCase(repository),
        deleteProductReviewUseCase: DeleteProductReviewUseCase(repository),
      );
      _isInternalController = true;
    }

    _controller.addListener(_handleStateChange);
    _controller.load();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChange);
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleStateChange() {
    if (!mounted) return;
    final state = _controller.state;

    if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
      final msg = state.errorMessage!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _controller.clearMessages();
    } else if (state.successMessage != null && state.successMessage!.isNotEmpty) {
      final msg = state.successMessage!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _controller.clearMessages();
    }
  }

  void _openCreateReviewBottomSheet() {
    if (widget.currentUserId == null) return;

    ReviewInputBottomSheet.show(
      context,
      onSubmit: ({required String content, required int rating}) {
        return _controller.createReview(
          userId: widget.currentUserId!,
          targetProfileId: widget.targetProfileId,
          content: content,
          rating: rating,
        );
      },
    );
  }

  void _openEditReviewBottomSheet(Comment comment) {
    ReviewInputBottomSheet.show(
      context,
      initialComment: comment,
      onSubmit: ({required String content, required int rating}) {
        return _controller.updateReview(
          commentId: comment.id,
          content: content,
          rating: rating,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('Opiniones y Reputación'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E293B),
            elevation: 0.5,
          ),
          floatingActionButton: _canWriteReview
              ? FloatingActionButton.extended(
                  key: const Key('add_review_fab'),
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text(
                    'Escribir opinión',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onPressed: _openCreateReviewBottomSheet,
                )
              : null,
          body: RefreshIndicator(
            color: primaryGreen,
            onRefresh: () => _controller.load(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Rating summary card section
                if (state.summary != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: RatingSummaryCard(
                        summary: state.summary!,
                        onRatingBarTap: (stars) {
                          _controller.setRatingFilter(stars);
                        },
                      ),
                    ),
                  ),

                // Star filter chips
                SliverToBoxAdapter(
                  child: RatingFilterChips(
                    selectedRating: state.selectedRatingFilter,
                    summary: state.summary,
                    onSelected: (rating) {
                      _controller.setRatingFilter(rating);
                    },
                  ),
                ),

                // Comments count headline
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          state.selectedRatingFilter == null
                              ? 'Todas las opiniones (${state.comments.length})'
                              : 'Opiniones con ${state.selectedRatingFilter} ★ (${state.comments.length})',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Loading spinner
                if (state.isLoading && state.comments.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: primaryGreen),
                    ),
                  )
                // Empty state
                else if (state.comments.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.rate_review_outlined,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Aún no hay opiniones para este filtro.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '¡Sé el primero en compartir tu experiencia!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                // Comments list
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final comment = state.comments[index];
                        return CommentListItem(
                          comment: comment,
                          currentUserId: widget.currentUserId,
                          onEdit: () => _openEditReviewBottomSheet(comment),
                          onDelete: () => _controller.deleteReview(comment.id),
                        );
                      },
                      childCount: state.comments.length,
                    ),
                  ),

                // Bottom padding for FAB clearance
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
