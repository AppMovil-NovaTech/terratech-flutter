import 'package:dio/dio.dart';

import '../../core/errors/problem_details.dart';
import '../../core/network/dio_client.dart';
import '../domain/product_notification.dart';
import '../domain/product_notifications_repository.dart';

class ProductNotificationsRepositoryImpl implements ProductNotificationsRepository {
  ProductNotificationsRepositoryImpl({required DioClient dioClient}) : _dio = dioClient.dio;
  final Dio _dio;

  @override
  Future<List<ProductNotification>> getNotifications() async {
    try {
      // Backend global query filters limit this endpoint to the current profile.
      final response = await _dio.get<dynamic>('/api/v1/notifications');
      if (response.data is! List) {
        throw const FormatException('Respuesta de notificaciones no válida.');
      }
      final notifications = (response.data as List).map((item) {
        if (item is! Map) {
          throw const FormatException('Notificación no válida.');
        }
        final data = item.map((k, v) => MapEntry(k.toString(), v));
        return ProductNotification(
          id: (data['id'] as num).toInt(),
          title: data['title']?.toString() ?? '',
          message: data['message']?.toString() ?? '',
          isRead: data['isRead'] == true,
          isAlert: data['isAlert'] == true,
          createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? ''),
        );
      }).toList(growable: false);
      notifications.sort((a, b) => (b.createdAt ?? DateTime(1970))
          .compareTo(a.createdAt ?? DateTime(1970)));
      return notifications;
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  @override
  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.put<void>('/api/v1/notifications/$notificationId/reads');
    } on DioException catch (error) {
      throw _asProblem(error);
    }
  }

  ProblemDetails _asProblem(DioException error) {
    if (error.error is ProblemDetails) return error.error! as ProblemDetails;
    return ProblemDetails(
      title: 'No se pudieron consultar las notificaciones',
      status: error.response?.statusCode,
      detail: error.response?.statusCode == 401
          ? 'Inicia sesión para consultar las alertas.'
          : error.message ?? 'Error de conexión.',
    );
  }
}
