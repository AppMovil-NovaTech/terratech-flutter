import 'package:equatable/equatable.dart';

sealed class ProductNotificationsEvent extends Equatable {
  const ProductNotificationsEvent();
  @override
  List<Object?> get props => const <Object?>[];
}

final class LoadProductNotificationsRequested extends ProductNotificationsEvent {
  const LoadProductNotificationsRequested();
}

final class MarkProductNotificationReadRequested extends ProductNotificationsEvent {
  const MarkProductNotificationReadRequested(this.id);
  final int id;
  @override
  List<Object?> get props => <Object?>[id];
}
