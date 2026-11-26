import 'package:equatable/equatable.dart';

/// US29: supplier actions for owned-product interest settings.
sealed class ProductInterestEvent extends Equatable {
  const ProductInterestEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class LoadProductInterestRequested extends ProductInterestEvent {
  const LoadProductInterestRequested({required this.productId});
  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}

final class UpdateProductInterestThresholdRequested
    extends ProductInterestEvent {
  const UpdateProductInterestThresholdRequested({
    required this.productId,
    required this.threshold,
  });
  final int productId;
  final int threshold;

  @override
  List<Object?> get props => <Object?>[productId, threshold];
}

final class CheckProductInactivityRequested extends ProductInterestEvent {
  const CheckProductInactivityRequested({required this.productId});
  final int productId;

  @override
  List<Object?> get props => <Object?>[productId];
}
