import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/router/app_routes.dart';
import '../data/commercial_remote_datasource.dart';
import '../domain/commercial_repository.dart';
import '../domain/product.dart';
import 'catalog_bloc.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';
import 'product_detail_screen.dart';
import 'widgets/catalog_feedback_views.dart';
import 'widgets/catalog_filter_header.dart';
import 'widgets/product_catalog_cards.dart';
import 'widgets/simultaneous_filter_sheet.dart';

/// Material 3 Product Catalog Screen implementing User Story US39:
/// - Scenario 1: Displays product grid/list with image, name, price, origin
///   region, and average rating.
/// - Scenario 2: Simultaneous filtering by category and origin region.
/// - Scenario 3: Real-time search bar in the header filtering by partial or
///   total product name match.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({
    super.key,
    required this.repository,
    this.bloc,
  });

  final CommercialRepository repository;
  final CatalogBloc? bloc;

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  late final CatalogBloc _catalogBloc;
  late final bool _ownsBloc;
  final TextEditingController _searchController = TextEditingController();
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _ownsBloc = widget.bloc == null;
    _catalogBloc = widget.bloc ?? CatalogBloc(repository: widget.repository);
    if (_catalogBloc.state.status == CatalogStatus.initial) {
      _catalogBloc.add(const LoadCatalogRequested());
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsBloc) {
      _catalogBloc.close();
    }
    super.dispose();
  }

  void _openProductDetail(Product product) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(
          name: AppRoutes.productDetail,
          arguments: ProductDetailRouteArgs(
            productId: product.id,
            initialProduct: product,
          ),
        ),
        builder: (_) => ProductDetailScreen(
          productId: product.id,
          initialProduct: product,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _openFilterModal(BuildContext context, CatalogState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => SimultaneousFilterSheet(
        availableCategories: state.availableCategories,
        availableRegions: state.availableRegions,
        initialCategory: state.selectedCategory,
        initialRegion: state.selectedRegion,
        onApply: (category, region) {
          _catalogBloc.add(
            CatalogFiltersApplied(category: category, region: region),
          );
        },
        onClear: () {
          _searchController.clear();
          _catalogBloc.add(const CatalogFiltersCleared());
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider<CatalogBloc>.value(
      value: _catalogBloc,
      child: BlocConsumer<CatalogBloc, CatalogState>(
        listenWhen: (previous, current) =>
            previous.searchQuery != current.searchQuery &&
            current.searchQuery.isEmpty &&
            _searchController.text.isNotEmpty,
        listener: (context, state) {
          _searchController.clear();
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: AppBar(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'Catálogo Agrícola TerraTech',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        'TerraTech Home',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          ' • ${MockAuthSession.testUserEmail}',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onPrimary.withValues(
                              alpha: 0.85,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: <Widget>[
                IconButton(
                  key: const Key('catalog_toggle_view_button'),
                  tooltip: _isGridView
                      ? 'Cambiar a vista de lista'
                      : 'Cambiar a vista de cuadrícula',
                  icon: Icon(
                    _isGridView
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
                Badge(
                  isLabelVisible: state.activeFilterCount > 0,
                  label: Text('${state.activeFilterCount}'),
                  child: IconButton(
                    key: const Key('catalog_open_filters_button'),
                    tooltip: 'Filtros avanzados por categoría y región',
                    icon: const Icon(Icons.tune_rounded),
                    onPressed: () => _openFilterModal(context, state),
                  ),
                ),
                IconButton(
                  key: const Key('catalog_refresh_button'),
                  tooltip: 'Actualizar catálogo',
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => _catalogBloc.add(
                    const LoadCatalogRequested(preserveFilters: true),
                  ),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                CatalogFilterHeader(
                  searchController: _searchController,
                  state: state,
                  onSearchChanged: (value) {
                    _catalogBloc.add(CatalogSearchQueryChanged(value));
                  },
                  onClearSearch: () {
                    _searchController.clear();
                    _catalogBloc.add(const CatalogSearchQueryChanged(''));
                  },
                  onCategorySelected: (category) {
                    _catalogBloc.add(CatalogCategoryFilterChanged(category));
                  },
                  onRegionSelected: (region) {
                    _catalogBloc.add(CatalogRegionFilterChanged(region));
                  },
                  onClearAllFilters: () {
                    _searchController.clear();
                    _catalogBloc.add(const CatalogFiltersCleared());
                  },
                ),
                Expanded(
                  child: _buildCatalogBody(context, state),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogBody(BuildContext context, CatalogState state) {
    switch (state.status) {
      case CatalogStatus.initial:
      case CatalogStatus.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando productos agrícolas verificados...'),
            ],
          ),
        );

      case CatalogStatus.failure:
        return CatalogErrorView(
          message:
              state.errorMessage ??
              'Ocurrió un error al consultar el catálogo.',
          onRetry: () => _catalogBloc.add(const LoadCatalogRequested()),
        );

      case CatalogStatus.success:
        if (state.filteredProducts.isEmpty) {
          return CatalogEmptyResultView(
            hasActiveFilters: state.hasActiveFilters,
            onClearFilters: () {
              _searchController.clear();
              _catalogBloc.add(const CatalogFiltersCleared());
            },
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            _catalogBloc.add(const LoadCatalogRequested(preserveFilters: true));
          },
          child: _isGridView
              ? GridView.builder(
                  key: const Key('catalog_product_grid'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 260,
                    mainAxisExtent: 310,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: state.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    return ProductGridCard(
                      product: product,
                      onTap: () => _openProductDetail(product),
                    );
                  },
                )
              : ListView.separated(
                  key: const Key('catalog_product_list'),
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: state.filteredProducts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = state.filteredProducts[index];
                    return ProductListTileCard(
                      product: product,
                      onTap: () => _openProductDetail(product),
                    );
                  },
                ),
        );
    }
  }
}
