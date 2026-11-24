import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/product_preferences_repository.dart';
import 'product_preferences_bloc.dart';
import 'product_preferences_event.dart';
import 'product_preferences_state.dart';

/// US31: opt in to notifications for future product publications by type.
class ProductPreferencesScreen extends StatefulWidget {
  const ProductPreferencesScreen({super.key, required this.repository});

  final ProductPreferencesRepository repository;

  @override
  State<ProductPreferencesScreen> createState() =>
      _ProductPreferencesScreenState();
}

class _ProductPreferencesScreenState extends State<ProductPreferencesScreen> {
  late final ProductPreferencesBloc _bloc;
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bloc = ProductPreferencesBloc(repository: widget.repository)
      ..add(const LoadProductPreferencesRequested());
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductPreferencesBloc>.value(
      value: _bloc,
      child: BlocConsumer<ProductPreferencesBloc, ProductPreferencesState>(
        listenWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage &&
            current.errorMessage != null,
        listener: (context, state) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(state.errorMessage!))),
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text('Preferencias de productos'),
            actions: <Widget>[
              IconButton(
                tooltip: 'Actualizar preferencias',
                onPressed: state.isSaving
                    ? null
                    : () => _bloc.add(const LoadProductPreferencesRequested()),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: state.status == ProductPreferencesStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : state.status == ProductPreferencesStatus.failure
                  ? Center(
                      child: FilledButton(
                        onPressed: () => _bloc.add(
                          const LoadProductPreferencesRequested(),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: <Widget>[
                        const Text(
                          'Recibe una notificación cuando se publique un '
                          'producto de uno de los tipos que te interesan.',
                        ),
                        const SizedBox(height: 16),
                        Text('Mis preferencias',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (state.selectedCategories.isEmpty)
                          const Text('Aún no tienes preferencias guardadas.'),
                        ...state.selectedCategories.map(
                          (category) => ListTile(
                            key: Key('us31_saved_$category'),
                            title: Text(category),
                            trailing: IconButton(
                              tooltip: 'Quitar preferencia',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: state.isSaving
                                  ? null
                                  : () => _bloc.add(
                                      UnsubscribeProductCategoryRequested(
                                          category),
                                    ),
                            ),
                          ),
                        ),
                        const Divider(),
                        Text('Tipos publicados',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        if (state.availableCategories.isEmpty)
                          const Text('No hay tipos publicados todavía.'),
                        Wrap(
                          spacing: 8,
                          children: state.availableCategories.map((category) {
                            final subscribed = state.selectedCategories.any(
                              (saved) =>
                                  saved.toLowerCase() == category.toLowerCase(),
                            );
                            return FilterChip(
                              label: Text(category),
                              selected: subscribed,
                              onSelected: state.isSaving
                                  ? null
                                  : (selected) => _bloc.add(selected
                                      ? SubscribeProductCategoryRequested(
                                          category)
                                      : UnsubscribeProductCategoryRequested(
                                          category)),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        Text('Otro tipo de producto',
                            style: Theme.of(context).textTheme.titleMedium),
                        TextField(
                          key: const Key('us31_custom_category_field'),
                          controller: _categoryController,
                          maxLength: 50,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            hintText: 'Ej.: Frutas',
                            helperText: 'Se comparará con el tipo publicado.',
                          ),
                        ),
                        const SizedBox(height: 8),
                        FilledButton.icon(
                          key: const Key('us31_subscribe_category_button'),
                          onPressed: state.isSaving
                              ? null
                              : () {
                                  final category = _categoryController.text.trim();
                                  if (category.isEmpty) return;
                                  _bloc.add(
                                      SubscribeProductCategoryRequested(category));
                                  _categoryController.clear();
                                },
                          icon: const Icon(Icons.notifications_active_outlined),
                          label: const Text('Guardar preferencia'),
                        ),
                        if (state.isSaving)
                          const Padding(
                            padding: EdgeInsets.all(12),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                      ],
                    ),
        ),
      ),
    );
  }
}
