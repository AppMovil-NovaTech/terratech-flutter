import 'package:equatable/equatable.dart';
import '../domain/product_notification.dart';

enum ProductNotificationsStatus { initial, loading, success, failure }

final class ProductNotificationsState extends Equatable {
  const ProductNotificationsState({
    this.status = ProductNotificationsStatus.initial,
    this.items = const <ProductNotification>[],
    this.errorMessage,
    this.updatingId,
  });

  final ProductNotificationsStatus status;
  final List<ProductNotification> items;
  final String? errorMessage;
  final int? updatingId;

  ProductNotificationsState copyWith({
    ProductNotificationsStatus? status,
    List<ProductNotification>? items,
    String? Function()? errorMessage,
    int? Function()? updatingId,
  }) => ProductNotificationsState(
    status: status ?? this.status,
    items: items ?? this.items,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    updatingId: updatingId != null ? updatingId() : this.updatingId,
  );

  @override
  List<Object?> get props => <Object?>[status, items, errorMessage, updatingId];
}
