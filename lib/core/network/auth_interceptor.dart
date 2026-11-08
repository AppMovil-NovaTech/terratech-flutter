import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';

/// Intercepts outgoing HTTP requests and injects the bearer JWT token
/// stored in [SecureStorage] into the `Authorization` header.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.secureStorage});

  static const String _authorizationHeader = 'Authorization';
  static const String _bearerPrefix = 'Bearer';

  final SecureStorage secureStorage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await secureStorage.getToken();
      if (token != null && token.trim().isNotEmpty) {
        options.headers[_authorizationHeader] = '$_bearerPrefix ${token.trim()}';
      }
    } catch (_) {
      // Proceed without Authorization header if secure storage cannot be read;
      // protected endpoints will respond with 401 ProblemDetails.
    }

    handler.next(options);
  }
}
