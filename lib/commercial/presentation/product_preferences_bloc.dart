import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/product_preferences_repository.dart';
import 'product_preferences_event.dart';
import 'product_preferences_state.dart';

class ProductPreferencesBloc
    extends Bloc<ProductPreferencesEvent, ProductPreferencesState> {
  ProductPreferencesBloc({required this.repository})
      : super(const ProductPreferencesState()) {
    on<LoadProductPreferencesRequested>(_onLoad);
    on<SubscribeProductCategoryRequested>(_onSubscribe);
    on<UnsubscribeProductCategoryRequested>(_onUnsubscribe);
  }

  final ProductPreferencesRepository repository;

  Future<void> _onLoad(
    LoadProductPreferencesRequested event,
    Emitter<ProductPreferencesState> emit,
  ) async {
    emit(state.copyWith(
      status: ProductPreferencesStatus.loading,
      errorMessage: () => null,
    ));
    try {
      final categories = await repository.getAvailableCategories();
      final selected = await repository.getMyPreferences();
      emit(state.copyWith(
        status: ProductPreferencesStatus.success,
        availableCategories: categories,
        selectedCategories: selected,
      ));
    } catch (error) {
      emit(state.copyWith(
        status: ProductPreferencesStatus.failure,
        errorMessage: () => error.toString(),
      ));
    }
  }

  Future<void> _onSubscribe(
    SubscribeProductCategoryRequested event,
    Emitter<ProductPreferencesState> emit,
  ) async {
    if (state.isSaving) return;
    final category = event.category.trim();
    if (category.isEmpty || category.length > 50) return;
    emit(state.copyWith(isSaving: true, errorMessage: () => null));
    try {
      await repository.subscribe(category);
      final updated = await repository.getMyPreferences();
      emit(state.copyWith(selectedCategories: updated, isSaving: false));
    } catch (error) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: () => error.toString(),
      ));
    }
  }

  Future<void> _onUnsubscribe(
    UnsubscribeProductCategoryRequested event,
    Emitter<ProductPreferencesState> emit,
  ) async {
    if (state.isSaving) return;
    emit(state.copyWith(isSaving: true, errorMessage: () => null));
    try {
      await repository.unsubscribe(event.category);
      final updated = await repository.getMyPreferences();
      emit(state.copyWith(selectedCategories: updated, isSaving: false));
    } catch (error) {
      emit(state.copyWith(
        isSaving: false,
        errorMessage: () => error.toString(),
      ));
    }
  }
}
