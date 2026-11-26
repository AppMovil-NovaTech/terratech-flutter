import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/problem_details.dart';
import '../domain/product_notifications_repository.dart';
import 'product_notifications_event.dart';
import 'product_notifications_state.dart';

class ProductNotificationsBloc extends Bloc<ProductNotificationsEvent, ProductNotificationsState> {
  ProductNotificationsBloc({required this.repository})
      : super(const ProductNotificationsState()) {
    on<LoadProductNotificationsRequested>(_onLoad);
    on<MarkProductNotificationReadRequested>(_onMarkRead);
  }

  final ProductNotificationsRepository repository;

  Future<void> _onLoad(
    LoadProductNotificationsRequested event,
    Emitter<ProductNotificationsState> emit,
  ) async {
    emit(state.copyWith(status: ProductNotificationsStatus.loading,
        errorMessage: () => null));
    try {
      final items = await repository.getNotifications();
      emit(state.copyWith(status: ProductNotificationsStatus.success, items: items));
    } on ProblemDetails catch (problem) {
      emit(state.copyWith(status: ProductNotificationsStatus.failure,
          errorMessage: () => problem.userMessage));
    } catch (_) {
      emit(state.copyWith(status: ProductNotificationsStatus.failure,
          errorMessage: () => 'No se pudieron cargar las notificaciones.'));
    }
  }

  Future<void> _onMarkRead(
    MarkProductNotificationReadRequested event,
    Emitter<ProductNotificationsState> emit,
  ) async {
    if (state.updatingId != null) return;
    emit(state.copyWith(updatingId: () => event.id, errorMessage: () => null));
    try {
      await repository.markAsRead(event.id);
      final updated = state.items.map((item) => item.id == event.id
          ? item.copyWith(isRead: true) : item).toList(growable: false);
      emit(state.copyWith(items: updated, updatingId: () => null));
    } on ProblemDetails catch (problem) {
      emit(state.copyWith(updatingId: () => null,
          errorMessage: () => problem.userMessage));
    } catch (_) {
      emit(state.copyWith(updatingId: () => null,
          errorMessage: () => 'No se pudo marcar la notificación como leída.'));
    }
  }
}
