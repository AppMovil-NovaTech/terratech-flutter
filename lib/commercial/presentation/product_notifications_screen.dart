import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/product_notifications_repository.dart';
import 'product_notifications_bloc.dart';
import 'product_notifications_event.dart';
import 'product_notifications_state.dart';

/// US32: notification inbox backed by the existing /api/v1/notifications API.
class ProductNotificationsScreen extends StatefulWidget {
  const ProductNotificationsScreen({super.key, required this.repository});
  final ProductNotificationsRepository repository;

  @override
  State<ProductNotificationsScreen> createState() => _ProductNotificationsScreenState();
}

class _ProductNotificationsScreenState extends State<ProductNotificationsScreen> {
  late final ProductNotificationsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProductNotificationsBloc(repository: widget.repository)
      ..add(const LoadProductNotificationsRequested());
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductNotificationsBloc>.value(
      value: _bloc,
      child: BlocConsumer<ProductNotificationsBloc, ProductNotificationsState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage && current.errorMessage != null,
        listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!))),
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Mis notificaciones'),
            actions: <Widget>[
              IconButton(
                key: const Key('us32_notifications_refresh_button'),
                tooltip: 'Actualizar notificaciones',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () => _bloc.add(const LoadProductNotificationsRequested()),
              ),
            ],
          ),
          body: switch (state.status) {
            ProductNotificationsStatus.initial || ProductNotificationsStatus.loading =>
                const Center(child: CircularProgressIndicator()),
            ProductNotificationsStatus.failure => Center(
                child: Text(state.errorMessage ?? 'Error al cargar notificaciones.')),
            ProductNotificationsStatus.success => state.items.isEmpty
                ? const Center(child: Text('Aún no tienes notificaciones.'))
                : ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ListTile(
                        key: Key('us32_notification_${item.id}'),
                        leading: Icon(item.isRead
                            ? Icons.notifications_none_rounded
                            : Icons.notifications_active_rounded),
                        title: Text(item.title,
                            style: TextStyle(fontWeight: item.isRead
                                ? FontWeight.normal : FontWeight.bold)),
                        subtitle: Text(item.message),
                        trailing: item.isRead
                            ? const Icon(Icons.done_rounded)
                            : IconButton(
                                tooltip: 'Marcar como leída',
                                onPressed: state.updatingId != null
                                    ? null
                                    : () => _bloc.add(MarkProductNotificationReadRequested(item.id)),
                                icon: const Icon(Icons.mark_email_read_outlined)),
                      );
                    },
                  ),
          },
        ),
      ),
    );
  }
}
