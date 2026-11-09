import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/router/app_routes.dart';
import '../data/commercial_remote_datasource.dart';
import '../domain/commercial_repository.dart';
import '../domain/product.dart';
import '../domain/traceability.dart';
import 'product_detail_bloc.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';
import 'widgets/contact_farmer_sheet.dart';
import 'widgets/product_image_gallery.dart';
import 'widgets/product_info_sections.dart';
import 'widgets/traceability_inquiry_section.dart';

/// Material 3 Product Detail & Traceability Screen implementing User Story US40:
/// - Scenario 1: Displays product name, images, price, description, origin
///   region, farmer name, traceability information, and registered cultivation
///   practices.
/// - Scenario 2: Dedicated traceability inquiry section outlining provenance,
///   farmer, crop, and associated production events using strictly registered
///   and authorized TerraTech data.
/// - Scenario 3: Functional "Contact Farmer" button utilizing the static user
///   context (`test.user@terratech.com`). Shopping cart is explicitly omitted.
class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    required this.repository,
    this.initialProduct,
    this.bloc,
  });

  final int productId;
  final CommercialRepository repository;
  final Product? initialProduct;
  final ProductDetailBloc? bloc;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late final ProductDetailBloc _detailBloc;
  late final bool _ownsBloc;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _detailBloc =
        widget.bloc ?? ProductDetailBloc(repository: widget.repository);
    if (_detailBloc.state.status == ProductDetailStatus.initial) {
      _detailBloc.add(
        LoadProductDetailRequested(
          productId: widget.productId,
          initialProduct: widget.initialProduct,
        ),
      );
    }
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    if (_ownsBloc) {
      _detailBloc.close();
    }
    super.dispose();
  }

  void _showContactFarmerSheet(BuildContext context, Product product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => BlocProvider<ProductDetailBloc>.value(
        value: _detailBloc,
        child: ContactFarmerBottomSheet(product: product),
      ),
    );
  }

  void _openProductReviews(BuildContext context, Product product) {
    Navigator.of(context).pushNamed(
      AppRoutes.community,
      arguments: CommunityScreenArgs(
        productId: product.id,
        targetProfileId: product.farmerProfileId,
        currentUserId: MockAuthSession.testUserId,
        productName: product.name,
      ),
    );
  }

  void _showQrTraceabilityCertificateDialog(
    BuildContext context,
    Product product,
    TraceabilityInfo traceability,
  ) {
    _detailBloc.add(
      TraceabilityInquiryRequested(
        qrVerificationCode: traceability.qrVerificationCode,
      ),
    );

    showDialog<void>(
      context: context,
      builder: (_) => QrTraceabilityCertificateDialog(
        product: product,
        traceability: traceability,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider<ProductDetailBloc>.value(
      value: _detailBloc,
      child: BlocConsumer<ProductDetailBloc, ProductDetailState>(
        listenWhen: (previous, current) =>
            previous.contactStatus != current.contactStatus,
        listener: (context, state) {
          if (state.contactStatus == ContactFarmerStatus.sent &&
              state.lastContactResult != null) {
            final result = state.lastContactResult!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                key: const Key('contact_farmer_success_snackbar'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.primary,
                content: Text(
                  'Solicitud enviada a ${result.farmerName} (${result.farmerPhone}) desde ${result.senderEmail}.',
                ),
              ),
            );
            _detailBloc.add(const ContactFarmerStatusReset());
          } else if (state.contactStatus == ContactFarmerStatus.failure &&
              state.contactErrorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: colorScheme.error,
                content: Text(state.contactErrorMessage!),
              ),
            );
            _detailBloc.add(const ContactFarmerStatusReset());
          }
        },
        builder: (context, state) {
          final product = state.product;

          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              title: Text(
                product?.name ?? 'Detalle del Producto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              actions: <Widget>[
                if (product != null)
                  IconButton(
                    key: const Key('verify_qr_traceability_appbar_button'),
                    tooltip: 'Consultar ficha QR de trazabilidad',
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    onPressed: () => _showQrTraceabilityCertificateDialog(
                      context,
                      product,
                      state.traceability ?? product.traceability,
                    ),
                  ),
              ],
            ),
            body: _buildBody(context, state),
            bottomNavigationBar: product != null
                ? ContactFarmerBottomBar(
                    product: product,
                    onContactPressed: () =>
                        _showContactFarmerSheet(context, product),
                  )
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailState state) {
    if (state.status == ProductDetailStatus.loading && state.product == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando información y trazabilidad del producto...'),
          ],
        ),
      );
    }

    if (state.status == ProductDetailStatus.failure && state.product == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.error_outline_rounded,
                size: 52,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                state.errorMessage ?? 'No se pudo cargar el producto.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _detailBloc.add(
                  LoadProductDetailRequested(productId: widget.productId),
                ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final product = state.product;
    if (product == null) {
      return const SizedBox.shrink();
    }

    final traceability = state.traceability ?? product.traceability;
    final gallery = product.images.isNotEmpty
        ? product.images
        : <String>[product.imageUrl];

    return SingleChildScrollView(
      key: const Key('product_detail_scroll_view'),
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ProductImageGallery(
            images: gallery,
            category: product.category,
            pageController: _imagePageController,
            currentIndex: _currentImageIndex,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ProductPrimaryHeaderCard(product: product),
                const SizedBox(height: 16),
                FarmerInformationCard(
                  product: product,
                  traceability: traceability,
                  onContactPressed: () =>
                      _showContactFarmerSheet(context, product),
                ),
                const SizedBox(height: 16),
                SectionContainerCard(
                  title: 'Descripción del Producto',
                  icon: Icons.description_outlined,
                  child: Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CultivationPracticesSection(
                  practices: product.cultivationPractices,
                ),
                const SizedBox(height: 16),
                TraceabilityInquirySection(
                  product: product,
                  traceability: traceability,
                  onVerifyQrPressed: () => _showQrTraceabilityCertificateDialog(
                    context,
                    product,
                    traceability,
                  ),
                ),
                const SizedBox(height: 16),
                SectionContainerCard(
                  title: 'Opiniones y Reputación de Compradores',
                  icon: Icons.reviews_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFFFE082),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFF9A825),
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  product.averageRating.toStringAsFixed(1),
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF5D4037),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Basado en ${product.reviewCount} reseñas verificadas de compradores en la comunidad TerraTech.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          key: const Key('open_product_reviews_button'),
                          onPressed: () =>
                              _openProductReviews(context, product),
                          icon: const Icon(Icons.rate_review_outlined),
                          label: const Text('Ver opiniones y calificar'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
