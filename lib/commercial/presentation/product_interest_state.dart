import 'package:equatable/equatable.dart';

import '../domain/product_interest.dart';

enum ProductInterestStatus {
  initial,
  loading,
  ready,
  saving,
  checking,
  failure,
}

final class ProductInterestState extends Equatable {
  const ProductInterestState({
    this.status = ProductInterestStatus.initial,
    this.interest,
    this.message,
    this.errorMessage,
  });

  final ProductInterestStatus status;
  final ProductInterest? interest;
  final String? message;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[status, interest, message, errorMessage];
}
