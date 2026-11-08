import 'package:equatable/equatable.dart';

import '../domain/product.dart';

/// Base class for all events handled by `ProductDetailBloc` (US40).
sealed class ProductDetailEvent extends Equatable {
  const ProductDetailEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

/// Requests loading the complete detail, cultivation practices, and authorized
/// traceability of a product by [productId] (US40 - Scenario 1).
final class LoadProductDetailRequested extends ProductDetailEvent {
  const LoadProductDetailRequested({
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final Product? initialProduct;

  @override
  List<Object?> get props => <Object?>[productId, initialProduct];
}

/// Explicitly queries or refreshes the product's authorized TerraTech
/// traceability ficha (from catalog or QR code lookup, US40 - Scenario 2).
final class TraceabilityInquiryRequested extends ProductDetailEvent {
  const TraceabilityInquiryRequested({this.qrVerificationCode});

  final String? qrVerificationCode;

  @override
  List<Object?> get props => <Object?>[qrVerificationCode];
}

/// Submits a direct contact message to the product's farmer utilizing the
/// static authenticated user session (US40 - Scenario 3).
final class ContactFarmerSubmitted extends ProductDetailEvent {
  const ContactFarmerSubmitted({required this.message});

  final String message;

  @override
  List<Object?> get props => <Object?>[message];
}

/// Resets the transient contact submission status after displaying feedback.
final class ContactFarmerStatusReset extends ProductDetailEvent {
  const ContactFarmerStatusReset();
}
