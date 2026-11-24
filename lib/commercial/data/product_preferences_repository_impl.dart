import 'package:dio/dio.dart';

import '../../core/errors/problem_details.dart';
import '../../core/network/dio_client.dart';
import '../domain/product_preferences_repository.dart';

/// US31 preferences are stored by the authenticated user's profile in the API.
class ProductPreferencesRepositoryImpl implements ProductPreferencesRepository {
  ProductPreferencesRepositoryImpl({required DioClient dioClient})
      : _dio = dioClient.dio;

  final Dio _dio;
  static const String _path = '/api/v1/product-preferences';

  @override
  Future<List<String>> getMyPreferences() => _fetchList(_path);

  @override
  Future<List<String>> getAvailableCategories() =>
      _fetchList('$_path/categories');

  Future<List<String>> _fetchList(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
      final data = response.data;
      if (data is! List) {
        throw const FormatException('Respuesta inesperada de preferencias.');
      }
      return data.map((item) => item.toString()).toList(growable: false);
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  @override
  Future<void> subscribe(String category) async {
    try {
      await _dio.post<void>(_path, data: <String, String>{'category': category});
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  @override
  Future<void> unsubscribe(String category) async {
    try {
      await _dio.delete<void>(_path,
          queryParameters: <String, String>{'category': category});
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  ProblemDetails _asProblem(DioException error) {
    if (error.error is ProblemDetails) return error.error! as ProblemDetails;
    return ProblemDetails(
      title: 'No se pudieron actualizar las preferencias',
      status: error.response?.statusCode,
      detail: error.response?.statusCode == 401
          ? 'Inicia sesión para configurar tus alertas.'
          : error.message ?? 'Comprueba tu conexión con TerraTech.',
    );
  }
}
