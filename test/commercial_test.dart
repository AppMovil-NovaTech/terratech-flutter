import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/commercial/data/commercial_remote_datasource.dart';
import 'package:terratech_mobile/commercial/data/commercial_repository_impl.dart';
import 'package:terratech_mobile/commercial/data/product_model.dart';
import 'package:terratech_mobile/commercial/data/traceability_model.dart';
import 'package:terratech_mobile/commercial/domain/commercial_repository.dart';
import 'package:terratech_mobile/commercial/domain/product.dart';
import 'package:terratech_mobile/commercial/domain/traceability.dart';
import 'package:terratech_mobile/commercial/presentation/catalog_bloc.dart';
import 'package:terratech_mobile/commercial/presentation/catalog_event.dart';
import 'package:terratech_mobile/commercial/presentation/catalog_screen.dart';
import 'package:terratech_mobile/commercial/presentation/catalog_state.dart';
import 'package:terratech_mobile/commercial/presentation/product_detail_screen.dart';
import 'package:terratech_mobile/core/errors/problem_details.dart';
import 'package:terratech_mobile/core/storage/secure_storage.dart';

class _FakeSecureStorage implements SecureStorage {
  final Map<String, String> _data = <String, String>{};
  static const String _tokenKey = 'jwt';

  @override
  Future<void> clearAll() async => _data.clear();

  @override
  Future<void> delete(String key) async => _data.remove(key);

  @override
  Future<void> deleteToken() async => _data.remove(_tokenKey);

  @override
  Future<String?> getToken() async => _data[_tokenKey];

  @override
  Future<String?> read(String key) async => _data[key];

  @override
  Future<void> saveToken(String token) async => _data[_tokenKey] = token;

  @override
  Future<void> write({required String key, required String value}) async =>
      _data[key] = value;
}

class _FakeCommercialRepository implements CommercialRepository {
  _FakeCommercialRepository({
    required this.products,
    this.shouldFail = false,
  });

  final List<Product> products;
  final bool shouldFail;

  @override
  Future<List<Product>> getProducts({
    String? category,
    String? region,
    String? searchQuery,
  }) async {
    if (shouldFail) {
      throw const ProblemDetails(
        title: 'Service Unavailable',
        status: 503,
        detail: 'No se pudo conectar con el servidor de catálogo.',
      );
    }
    return CommercialRepositoryImpl.filterProducts(
      products: products,
      category: category,
      region: region,
      searchQuery: searchQuery,
    );
  }

  @override
  Future<Product> getProductById(int id) async {
    if (shouldFail) {
      throw const ProblemDetails(
        title: 'Product Not Found',
        status: 404,
        detail: 'Producto no encontrado.',
      );
    }
    return products.firstWhere(
      (p) => p.id == id,
      orElse: () => products.first,
    );
  }

  @override
  Future<TraceabilityInfo> getProductTraceability(int productId) async {
    final product = await getProductById(productId);
    return product.traceability;
  }

  @override
  Future<FarmerContactResult> contactFarmer({
    required Product product,
    required String message,
  }) async {
    return FarmerContactResult(
      productId: product.id,
      productName: product.name,
      farmerName: product.farmerName,
      farmerPhone: product.farmerPhone ?? '+51 984 512 309',
      senderEmail: MockAuthSession.testUserEmail,
      senderName: MockAuthSession.testUserFullName,
      message: message,
      sentAt: DateTime.utc(2026, 11, 8),
      notificationCreated: true,
    );
  }
}

List<ProductModel> _buildSampleCatalog() {
  return <ProductModel>[
    ProductModel.fromJson(const <String, dynamic>{
      'id': 1,
      'name': 'Papa Nativa Huayro Orgánica',
      'description': 'Cultivada en el Valle Sagrado del Cusco.',
      'price': 6.80,
      'type': 'Tubérculos',
      'originRegion': 'Cusco',
      'averageRating': 4.9,
      'farmerName': 'Cooperativa Agrícola Valle Andino',
      'imageUrl': 'https://example.com/papa.jpg',
    }),
    ProductModel.fromJson(const <String, dynamic>{
      'id': 2,
      'name': 'Quinua Real Blanca de Altura',
      'description': 'Grano andino seleccionado en Cusco.',
      'price': 14.50,
      'type': 'Granos Andinos',
      'originRegion': 'Cusco',
      'averageRating': 4.8,
      'farmerName': 'Cooperativa Agrícola Valle Andino',
      'imageUrl': 'https://example.com/quinua.jpg',
    }),
    ProductModel.fromJson(const <String, dynamic>{
      'id': 3,
      'name': 'Café Especial Arábica Chanchamayo',
      'description': 'Café de altura cultivado bajo sombra en Junín.',
      'price': 32.00,
      'type': 'Café y Cacao',
      'originRegion': 'Junín',
      'averageRating': 5.0,
      'farmerName': 'Fundo Santa Rosa Chanchamayo',
      'imageUrl': 'https://example.com/cafe.jpg',
    }),
    ProductModel.fromJson(const <String, dynamic>{
      'id': 4,
      'name': 'Palta Hass de Exportación',
      'description': 'Palta cremosa cultivada con riego tecnificado en Ica.',
      'price': 9.90,
      'type': 'Frutas',
      'originRegion': 'Ica',
      'averageRating': 4.7,
      'farmerName': 'Fundo Villacurí Ica',
      'imageUrl': 'https://example.com/palta.jpg',
    }),
  ];
}

void main() {
  group('Commercial Domain & Data Models (DTOs)', () {
    test('MockAuthSession seeds static test user token into SecureStorage', () async {
      final storage = _FakeSecureStorage();
      await MockAuthSession.ensureSeeded(storage);

      expect(await storage.getToken(), equals(MockAuthSession.staticJwtToken));
      expect(
        await storage.read(MockAuthSession.userEmailStorageKey),
        equals('test.user@terratech.com'),
      );
    });

    test('ProductModel and TraceabilityModel serialize fromJson and toJson', () {
      final model = _buildSampleCatalog().first;
      final json = model.toJson();
      final roundTrip = ProductModel.fromJson(json);

      expect(roundTrip.id, equals(1));
      expect(roundTrip.name, equals('Papa Nativa Huayro Orgánica'));
      expect(roundTrip.category, equals('Tubérculos'));
      expect(roundTrip.originRegion, equals('Cusco'));
      expect(roundTrip.averageRating, equals(4.9));
      expect(roundTrip.traceability.authorizedInTerraTech, isTrue);
      expect(roundTrip.traceability.productionEvents, isNotEmpty);

      final traceJson = TraceabilityModel.fromEntity(roundTrip.traceability).toJson();
      final traceRoundTrip = TraceabilityModel.fromJson(traceJson);
      expect(traceRoundTrip.batchCode, equals(roundTrip.traceability.batchCode));
      expect(traceRoundTrip.originRegion, equals('Cusco'));
    });
  });

  group('US39 - CatalogBloc State Management', () {
    test('Scenario 1, 2 & 3: Loads catalog, filters by category+region, and searches by name', () async {
      final repository = _FakeCommercialRepository(products: _buildSampleCatalog());
      final bloc = CatalogBloc(repository: repository);

      // Scenario 1: Load catalog
      bloc.add(const LoadCatalogRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, equals(CatalogStatus.success));
      expect(bloc.state.allProducts.length, equals(4));
      expect(bloc.state.filteredProducts.length, equals(4));

      // Scenario 2: Simultaneous Category + Region filter
      bloc.add(
        const CatalogFiltersApplied(
          category: 'Tubérculos',
          region: 'Cusco',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.filteredProducts.length, equals(1));
      expect(
        bloc.state.filteredProducts.single.name,
        equals('Papa Nativa Huayro Orgánica'),
      );

      // Clear filters and test Scenario 3: Search by partial name
      bloc.add(const CatalogFiltersCleared());
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredProducts.length, equals(4));

      bloc.add(const CatalogSearchQueryChanged('arabica'));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.filteredProducts.length, equals(1));
      expect(
        bloc.state.filteredProducts.single.name,
        equals('Café Especial Arábica Chanchamayo'),
      );

      await bloc.close();
    });

    test('Emits failure state with RFC 7807 ProblemDetails message on error', () async {
      final repository = _FakeCommercialRepository(
        products: const <Product>[],
        shouldFail: true,
      );
      final bloc = CatalogBloc(repository: repository);

      bloc.add(const LoadCatalogRequested());
      await Future<void>.delayed(Duration.zero);

      expect(bloc.state.status, equals(CatalogStatus.failure));
      expect(
        bloc.state.errorMessage,
        equals('No se pudo conectar con el servidor de catálogo.'),
      );
      expect(bloc.state.problemDetails?.status, equals(503));

      await bloc.close();
    });
  });

  group('US39 & US40 - Widget Integration Tests', () {
    testWidgets('CatalogScreen displays products, filters in real-time, and navigates to ProductDetailScreen', (tester) async {
      final repository = _FakeCommercialRepository(products: _buildSampleCatalog());

      await tester.pumpWidget(
        MaterialApp(
          home: CatalogScreen(repository: repository),
        ),
      );
      await tester.pumpAndSettle();

      // US39 Scenario 1: Verify catalog cards display name, price, region, and rating
      expect(find.text('Papa Nativa Huayro Orgánica'), findsOneWidget);
      expect(find.text('S/ 6.80'), findsOneWidget);
      expect(find.text('4.9'), findsOneWidget);

      // US39 Scenario 3: Real-time search by name in header
      await tester.enterText(
        find.byKey(const Key('catalog_search_textfield')),
        'Papa Nativa',
      );
      await tester.pumpAndSettle();

      expect(find.text('Papa Nativa Huayro Orgánica'), findsOneWidget);
      expect(find.text('Café Especial Arábica Chanchamayo'), findsNothing);

      // Navigate to ProductDetailScreen (US40 Scenario 1)
      await tester.tap(find.byKey(const Key('product_card_1')));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailScreen), findsOneWidget);
      expect(find.text('Papa Nativa Huayro Orgánica'), findsWidgets);
      expect(find.text('Cooperativa Agrícola Valle Andino'), findsWidgets);
      expect(find.text('Prácticas de Cultivo Registradas'), findsOneWidget);

      // US40 Scenario 2: Verify dedicated Traceability section and authorization notice
      expect(find.byKey(const Key('traceability_inquiry_section')), findsOneWidget);
      expect(
        find.text('Información previamente registrada y autorizada en TerraTech'),
        findsOneWidget,
      );
      expect(find.text('Eventos de Producción Asociados'), findsOneWidget);

      // US40 Scenario 3: Verify "Contactar al Agricultor" action and absence of Shopping Cart
      expect(find.byKey(const Key('contact_farmer_primary_button')), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsNothing);

      await tester.tap(find.byKey(const Key('contact_farmer_primary_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('submit_contact_farmer_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('submit_contact_farmer_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('contact_farmer_success_snackbar')), findsOneWidget);
    });
  });
}
