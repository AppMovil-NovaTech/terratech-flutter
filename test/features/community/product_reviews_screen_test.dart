import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/commercial/data/commercial_remote_datasource.dart';
import 'package:terratech_mobile/commercial/data/product_model.dart';
import 'package:terratech_mobile/commercial/domain/commercial_repository.dart';
import 'package:terratech_mobile/commercial/domain/product.dart';
import 'package:terratech_mobile/commercial/domain/traceability.dart';
import 'package:terratech_mobile/commercial/presentation/product_detail_screen.dart';
import 'package:terratech_mobile/core/network/dio_client.dart';
import 'package:terratech_mobile/core/router/app_routes.dart';
import 'package:terratech_mobile/core/storage/secure_storage.dart';
import 'package:terratech_mobile/features/community/presentation/screens/product_reviews_screen.dart';

class _InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _store = <String, String>{};
  static const String _tokenKey = 'jwt';

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteToken() async => _store.remove(_tokenKey);

  @override
  Future<String?> getToken() async => _store[_tokenKey];

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> saveToken(String token) async => _store[_tokenKey] = token;

  @override
  Future<void> write({required String key, required String value}) async =>
      _store[key] = value;
}

class _FakeCommercialRepository implements CommercialRepository {
  _FakeCommercialRepository(this.product);

  final Product product;

  @override
  Future<List<Product>> getProducts({
    String? category,
    String? region,
    String? searchQuery,
  }) async => <Product>[product];

  @override
  Future<Product> getProductById(int id) async => product;

  @override
  Future<TraceabilityInfo> getProductTraceability(int productId) async =>
      product.traceability;

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
    );
  }
}

void main() {
  group('Community Route & MockAuthSession Integration Tests', () {
    test('CommunityScreenArgs defaults align with MockAuthSession.testUserId', () {
      const args = CommunityScreenArgs();
      expect(args.productId, equals(1));
      expect(args.targetProfileId, equals(1));
      expect(args.currentUserId, equals(MockAuthSession.testUserId));
      expect(args.currentUserId, equals(1));
      expect(args.productName, isNull);
    });

    testWidgets(
      'ProductDetailScreen navigates to AppRoutes.community with CommunityScreenArgs and MockAuthSession.testUserId',
      (tester) async {
        final storage = _InMemorySecureStorage();
        await MockAuthSession.ensureSeeded(storage);
        final dioClient = DioClient(
          secureStorage: storage,
          baseUrl: 'https://api.example.com',
        );

        final sampleProduct = ProductModel.fromJson(const <String, dynamic>{
          'id': 7,
          'name': 'Café Especial Arábica Chanchamayo',
          'description': 'Café de altura cultivado bajo sombra en Junín.',
          'price': 32.00,
          'type': 'Café y Cacao',
          'originRegion': 'Junín',
          'averageRating': 4.8,
          'reviewCount': 12,
          'farmerProfileId': 3,
          'farmerName': 'Fundo Santa Rosa Chanchamayo',
          'imageUrl': 'https://example.com/cafe.jpg',
        });

        final commercialRepo = _FakeCommercialRepository(sampleProduct);
        CommunityScreenArgs? capturedArgs;

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == AppRoutes.community &&
                  settings.arguments is CommunityScreenArgs) {
                capturedArgs = settings.arguments! as CommunityScreenArgs;
              }
              return AppRouter.onGenerateRoute(
                settings,
                commercialRepository: commercialRepo,
                dioClient: dioClient,
              );
            },
            home: ProductDetailScreen(
              productId: sampleProduct.id,
              initialProduct: sampleProduct,
              repository: commercialRepo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('Opiniones y Reputación de Compradores'),
          findsOneWidget,
        );
        final openReviewsButton = find.byKey(
          const Key('open_product_reviews_button'),
        );
        expect(openReviewsButton, findsOneWidget);

        await tester.ensureVisible(openReviewsButton);
        await tester.tap(openReviewsButton);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));

        expect(capturedArgs, isNotNull);
        expect(capturedArgs!.productId, equals(7));
        expect(capturedArgs!.targetProfileId, equals(3));
        expect(capturedArgs!.currentUserId, equals(MockAuthSession.testUserId));
        expect(
          capturedArgs!.productName,
          equals('Café Especial Arábica Chanchamayo'),
        );

        expect(find.byType(ProductReviewsScreen), findsOneWidget);
        expect(find.text('Opiniones y Reputación'), findsOneWidget);
        expect(
          find.text('Café Especial Arábica Chanchamayo'),
          findsWidgets,
        );
      },
    );
  });
}
