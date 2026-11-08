import 'dart:convert';

import 'package:dio/dio.dart';

import '../errors/problem_details.dart';

/// Intercepts [DioException] errors and normalizes them into RFC 7807
/// [ProblemDetails] objects attached to `DioException.error`.
class ErrorInterceptor extends Interceptor {
  const ErrorInterceptor();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final problemDetails = _mapToProblemDetails(err);

    handler.next(
      err.copyWith(
        error: problemDetails,
        message: problemDetails.userMessage,
      ),
    );
  }

  ProblemDetails _mapToProblemDetails(DioException err) {
    final statusCode = err.response?.statusCode;
    final instancePath = err.requestOptions.uri.path;
    final responseData = err.response?.data;

    final jsonMap = _extractJsonMap(responseData);
    if (jsonMap != null) {
      return ProblemDetails.fromJson(
        jsonMap,
        fallbackStatus: statusCode,
        fallbackInstance: instancePath,
      );
    }

    if (responseData is String && responseData.trim().isNotEmpty) {
      return ProblemDetails(
        title: _defaultTitleForStatus(statusCode, err.type),
        status: statusCode,
        detail: responseData.trim(),
        instance: instancePath,
      );
    }

    return switch (err.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ProblemDetails(
        type: 'https://datatracker.ietf.org/doc/html/rfc7231#section-6.5.7',
        title: 'Request Timeout',
        status: statusCode ?? 408,
        detail: 'The server took too long to respond. Please try again.',
        instance: instancePath,
      ),
      DioExceptionType.connectionError => ProblemDetails(
        title: 'Network Connection Error',
        status: statusCode ?? 503,
        detail:
            'Unable to reach the server. Please verify your internet connection.',
        instance: instancePath,
      ),
      DioExceptionType.cancel => ProblemDetails(
        title: 'Request Cancelled',
        status: statusCode ?? 499,
        detail: 'The request was cancelled before completion.',
        instance: instancePath,
      ),
      DioExceptionType.badCertificate => ProblemDetails(
        title: 'Untrusted Certificate',
        status: statusCode ?? 495,
        detail: 'Could not verify the security certificate of the server.',
        instance: instancePath,
      ),
      DioExceptionType.badResponse || DioExceptionType.unknown => ProblemDetails(
        title: _defaultTitleForStatus(statusCode, err.type),
        status: statusCode,
        detail: err.message ?? 'An unexpected network error occurred.',
        instance: instancePath,
      ),
    };
  }

  Map<String, dynamic>? _extractJsonMap( Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _defaultTitleForStatus(int? statusCode, DioExceptionType type) {
    return switch (statusCode) {
      400 => 'Bad Request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Resource Not Found',
      409 => 'Conflict',
      422 => 'Unprocessable Entity',
      500 => 'Internal Server Error',
      502 => 'Bad Gateway',
      503 => 'Service Unavailable',
      _ => 'Network Error',
    };
  }
}
