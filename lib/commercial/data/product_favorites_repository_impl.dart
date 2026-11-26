import 'package:dio/dio.dart';

import '../../core/errors/problem_details.dart';
import '../../core/network/dio_client.dart';
import '../domain/product_favorites_repository.dart';

/// US32 endpoints; the shared DioClient attaches the current JWT automatically.
class ProductFavoritesRepositoryImpl implements ProductFavoritesRepository {
  ProductFavoritesRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;

  final Dio _dio;

  String _path(int productId) => '/api/v1/products/$productId/favorite';

  @override
  Future<bool> isFavorite(int productId) async {
    try {
      final response = await _dio.get<dynamic>(_path(productId));
      if (response.data is Map && (response.data as Map)['isFavorite'] is bool) {
        return (response.data as Map)['isFavorite'] as bool;
      }
      throw const FormatException('Respuesta inesperada del servidor.');
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  @override
  Future<void> addFavorite(int productId) async {
    try {
      await _dio.post<void>(_path(productId));
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    try {
      await _dio.delete<void>(_path(productId));
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  ProblemDetails _asProblem(DioException error) {
    if (error.error is ProblemDetails) return error.error! as ProblemDetails;
    if (error.response?.statusCode == 401) {
      return const ProblemDetails(
        title: 'Sesión requerida',
        status: 401,
        detail: 'Inicia sesión para guardar productos favoritos.',
      );
    }
    return ProblemDetails(
      title: 'No se pudo actualizar favoritos',
      status: error.response?.statusCode,
      detail: error.message ?? 'No se pudo conectar con TerraTech.',
    );
  }
}
