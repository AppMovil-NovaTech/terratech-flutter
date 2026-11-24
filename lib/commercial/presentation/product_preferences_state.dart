import 'package:equatable/equatable.dart';

enum ProductPreferencesStatus { initial, loading, success, failure }

final class ProductPreferencesState extends Equatable {
  const ProductPreferencesState({
    this.status = ProductPreferencesStatus.initial,
    this.selectedCategories = const <String>[],
    this.availableCategories = const <String>[],
    this.isSaving = false,
    this.errorMessage,
  });

  final ProductPreferencesStatus status;
  final List<String> selectedCategories;
  final List<String> availableCategories;
  final bool isSaving;
  final String? errorMessage;

  ProductPreferencesState copyWith({
    ProductPreferencesStatus? status,
    List<String>? selectedCategories,
    List<String>? availableCategories,
    bool? isSaving,
    String? Function()? errorMessage,
  }) => ProductPreferencesState(
    status: status ?? this.status,
    selectedCategories: selectedCategories ?? this.selectedCategories,
    availableCategories: availableCategories ?? this.availableCategories,
    isSaving: isSaving ?? this.isSaving,
    errorMessage: errorMessage == null ? this.errorMessage : errorMessage(),
  );

  @override
  List<Object?> get props => <Object?>[
    status, selectedCategories, availableCategories, isSaving, errorMessage,
  ];
}
