import 'package:dio/dio.dart';

import '../config/env_config.dart';
import '../storage/secure_storage.dart';
import 'auth_interceptor.dart';
import 'error_interceptor.dart';

/// Centralized HTTP client wrapper around [Dio].
///
/// Configures base URL from [EnvConfig], explicit timeouts, standard JSON and
/// RFC 7807 headers, and attaches [AuthInterceptor] and [ErrorInterceptor].
class DioClient {
  DioClient({
    required SecureStorage secureStorage,
    String? baseUrl,
    Duration connectTimeout = defaultTimeout,
    Duration receiveTimeout = defaultTimeout,
    Duration sendTimeout = defaultTimeout,
    Dio? dio,
  }) {
    final resolvedBaseUrl = (baseUrl ?? EnvConfig.apiBaseUrl).trim();

    _dio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: resolvedBaseUrl,
            connectTimeout: connectTimeout,
            receiveTimeout: receiveTimeout,
            sendTimeout: sendTimeout,
            headers: const <String, String>{
              Headers.contentTypeHeader: Headers.jsonContentType,
              Headers.acceptHeader:
                  'application/json, application/problem+json',
            },
          ),
        );

    _dio.interceptors.addAll(<Interceptor>[
      AuthInterceptor(secureStorage: secureStorage),
      const ErrorInterceptor(),
    ]);
  }

  static const Duration defaultTimeout = Duration(seconds: 15);

  late final Dio _dio;

  /// Underlying configured [Dio] instance for consumption by bounded-context
  /// remote data sources (`commercial` and `community`).
  Dio get dio => _dio;
}
