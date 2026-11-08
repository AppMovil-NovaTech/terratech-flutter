import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/app.dart';
import 'package:terratech_mobile/core/config/env_config.dart';
import 'package:terratech_mobile/core/errors/problem_details.dart';
import 'package:terratech_mobile/core/network/auth_interceptor.dart';
import 'package:terratech_mobile/core/network/dio_client.dart';
import 'package:terratech_mobile/core/network/error_interceptor.dart';
import 'package:terratech_mobile/core/storage/secure_storage.dart';

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

void main() {
  group('Core infrastructure tests', () {
    test('EnvConfig.validate throws when API_BASE_URL is empty', () {
      expect(() => EnvConfig.validate(''), throwsStateError);
    });

    test('AuthInterceptor injects Bearer token when present', () async {
      final storage = _InMemorySecureStorage();
      await storage.saveToken('sample-jwt-token');

      final interceptor = AuthInterceptor(secureStorage: storage);
      final options = RequestOptions(path: '/orders');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(
        options.headers['Authorization'],
        equals('Bearer sample-jwt-token'),
      );
    });

    test('ErrorInterceptor maps RFC 7807 response into ProblemDetails', () {
      const interceptor = ErrorInterceptor();
      final requestOptions = RequestOptions(path: '/api/v1/products/42');
      final dioError = DioException(
        requestOptions: requestOptions,
        response: Response<Map<String, dynamic>>(
          requestOptions: requestOptions,
          statusCode: 404,
          data: <String, dynamic>{
            'type': 'https://example.com/probs/not-found',
            'title': 'Product not found',
            'status': 404,
            'detail': 'No product exists with ID 42.',
            'instance': '/api/v1/products/42',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      DioException? captured;
      final handler = _CaptureErrorHandler((err) => captured = err);
      interceptor.onError(dioError, handler);

      expect(captured, isNotNull);
      expect(captured!.error, isA<ProblemDetails>());
      final problem = captured!.error! as ProblemDetails;
      expect(problem.status, 404);
      expect(problem.title, 'Product not found');
      expect(problem.detail, 'No product exists with ID 42.');
    });

    testWidgets('TerraTechApp renders initial route', (tester) async {
      final storage = _InMemorySecureStorage();
      final dioClient = DioClient(
        secureStorage: storage,
        baseUrl: 'https://api.example.com',
      );

      await tester.pumpWidget(
        TerraTechApp(secureStorage: storage, dioClient: dioClient),
      );

      expect(find.text('TerraTech Home'), findsWidgets);
    });
  });
}

class _CaptureErrorHandler extends ErrorInterceptorHandler {
  _CaptureErrorHandler(this.onNextCalled);

  final void Function(DioException err) onNextCalled;

  @override
  void next(DioException err) {
    onNextCalled(err);
  }
}
