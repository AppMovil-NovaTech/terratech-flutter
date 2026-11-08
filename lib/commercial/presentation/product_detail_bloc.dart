import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/problem_details.dart';
import '../domain/commercial_repository.dart';
import 'product_detail_event.dart';
import 'product_detail_state.dart';

/// BLoC managing Product Detail, Traceability Inquiry, and Farmer Contact
/// workflows (US40 - Scenarios 1, 2, and 3).
class ProductDetailBloc extends Bloc<ProductDetailEvent, ProductDetailState> {
  ProductDetailBloc({required this.repository})
    : super(const ProductDetailState()) {
    on<LoadProductDetailRequested>(_onLoadProductDetailRequested);
    on<TraceabilityInquiryRequested>(_onTraceabilityInquiryRequested);
    on<ContactFarmerSubmitted>(_onContactFarmerSubmitted);
    on<ContactFarmerStatusReset>(_onContactFarmerStatusReset);
  }

  final CommercialRepository repository;

  Future<void> _onLoadProductDetailRequested(
    LoadProductDetailRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    emit(
      state.copyWith(
        status: event.initialProduct != null
            ? ProductDetailStatus.success
            : ProductDetailStatus.loading,
        product: () => event.initialProduct ?? state.product,
        traceability: () =>
            event.initialProduct?.traceability ?? state.traceability,
        isTraceabilityVerified:
            event.initialProduct?.traceability.authorizedInTerraTech ?? false,
        errorMessage: () => null,
        problemDetails: () => null,
      ),
    );

    try {
      final loadedProduct = await repository.getProductById(event.productId);
      emit(
        state.copyWith(
          status: ProductDetailStatus.success,
          product: () => loadedProduct,
          traceability: () => loadedProduct.traceability,
          isTraceabilityVerified:
              loadedProduct.traceability.authorizedInTerraTech,
          errorMessage: () => null,
          problemDetails: () => null,
        ),
      );
    } on ProblemDetails catch (problem) {
      if (state.product != null) {
        return;
      }
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: () => problem.userMessage,
          problemDetails: () => problem,
        ),
      );
    } catch (error) {
      if (state.product != null) {
        return;
      }
      emit(
        state.copyWith(
          status: ProductDetailStatus.failure,
          errorMessage: () =>
              'No se pudo cargar el detalle del producto: $error',
        ),
      );
    }
  }

  Future<void> _onTraceabilityInquiryRequested(
    TraceabilityInquiryRequested event,
    Emitter<ProductDetailState> emit,
  ) async {
    final currentProduct = state.product;
    if (currentProduct == null) return;

    try {
      final refreshedTraceability = await repository.getProductTraceability(
        currentProduct.id,
      );
      if (refreshedTraceability.authorizedInTerraTech) {
        emit(
          state.copyWith(
            traceability: () => refreshedTraceability,
            isTraceabilityVerified: true,
          ),
        );
      }
    } catch (_) {
      // Retain existing authorized traceability if refresh fails offline.
      emit(
        state.copyWith(
          isTraceabilityVerified:
              currentProduct.traceability.authorizedInTerraTech,
        ),
      );
    }
  }

  Future<void> _onContactFarmerSubmitted(
    ContactFarmerSubmitted event,
    Emitter<ProductDetailState> emit,
  ) async {
    final currentProduct = state.product;
    if (currentProduct == null) return;

    emit(
      state.copyWith(
        contactStatus: ContactFarmerStatus.submitting,
        contactErrorMessage: () => null,
      ),
    );

    try {
      final result = await repository.contactFarmer(
        product: currentProduct,
        message: event.message,
      );

      emit(
        state.copyWith(
          contactStatus: ContactFarmerStatus.sent,
          lastContactResult: () => result,
          contactErrorMessage: () => null,
        ),
      );
    } on ProblemDetails catch (problem) {
      emit(
        state.copyWith(
          contactStatus: ContactFarmerStatus.failure,
          contactErrorMessage: () => problem.userMessage,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          contactStatus: ContactFarmerStatus.failure,
          contactErrorMessage: () =>
              'No se pudo enviar la solicitud de contacto: $error',
        ),
      );
    }
  }

  void _onContactFarmerStatusReset(
    ContactFarmerStatusReset event,
    Emitter<ProductDetailState> emit,
  ) {
    emit(
      state.copyWith(
        contactStatus: ContactFarmerStatus.idle,
        contactErrorMessage: () => null,
      ),
    );
  }
}
