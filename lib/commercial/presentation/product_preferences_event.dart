import 'package:equatable/equatable.dart';

sealed class ProductPreferencesEvent extends Equatable {
  const ProductPreferencesEvent();
  @override
  List<Object?> get props => const <Object?>[];
}

final class LoadProductPreferencesRequested extends ProductPreferencesEvent {
  const LoadProductPreferencesRequested();
}

final class SubscribeProductCategoryRequested extends ProductPreferencesEvent {
  const SubscribeProductCategoryRequested(this.category);
  final String category;
  @override
  List<Object?> get props => <Object?>[category];
}

final class UnsubscribeProductCategoryRequested extends ProductPreferencesEvent {
  const UnsubscribeProductCategoryRequested(this.category);
  final String category;
  @override
  List<Object?> get props => <Object?>[category];
}
