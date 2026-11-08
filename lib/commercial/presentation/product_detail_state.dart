import 'package:equatable/equatable.dart';

import '../../core/errors/problem_details.dart';
import '../domain/product.dart';
import '../domain/traceability.dart';

/// Status of loading product details and traceability (US40).
enum ProductDetailStatus {
  initial,
  loading,
  success,
  failure,
}

/// Status of the "Contact Farmer" action (US40 - Scenario 3).
enum ContactFarmerStatus {
  idle,
  submitting,
  sent,
  failure,
}

/// Immutable state managed by `ProductDetailBloc` for US40.
final class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.initial,
    this.product,
    this.traceability,
    this.isTraceabilityVerified = false,
    this.contactStatus = ContactFarmerStatus.idle,
    this.lastContactResult,
    this.errorMessage,
    this.contactErrorMessage,
    this.problemDetails,
  });

  final ProductDetailStatus status;
  final Product? product;
  final TraceabilityInfo? traceability;
  final bool isTraceabilityVerified;
  final ContactFarmerStatus contactStatus;
  final FarmerContactResult? lastContactResult;
  final String? errorMessage;
  final String? contactErrorMessage;
  final ProblemDetails? problemDetails;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? Function()? product,
    TraceabilityInfo? Function()? traceability,
    bool? isTraceabilityVerified,
    ContactFarmerStatus? contactStatus,
    FarmerContactResult? Function()? lastContactResult,
    String? Function()? errorMessage,
    String? Function()? contactErrorMessage,
    ProblemDetails? Function()? problemDetails,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product != null ? product() : this.product,
      traceability: traceability != null ? traceability() : this.traceability,
      isTraceabilityVerified:
          isTraceabilityVerified ?? this.isTraceabilityVerified,
      contactStatus: contactStatus ?? this.contactStatus,
      lastContactResult: lastContactResult != null
          ? lastContactResult()
          : this.lastContactResult,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      contactErrorMessage: contactErrorMessage != null
          ? contactErrorMessage()
          : this.contactErrorMessage,
      problemDetails: problemDetails != null
          ? problemDetails()
          : this.problemDetails,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    product,
    traceability,
    isTraceabilityVerified,
    contactStatus,
    lastContactResult,
    errorMessage,
    contactErrorMessage,
    problemDetails,
  ];
}
