import 'product_notification.dart';

abstract interface class ProductNotificationsRepository {
  Future<List<ProductNotification>> getNotifications();
  Future<void> markAsRead(int notificationId);
}
