import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/errors/problem_details.dart';
import '../domain/commercial_repository.dart';
import 'product_interest_event.dart';
import 'product_interest_state.dart';

/// US29 supplier interest management using the project's existing BLoC pattern.
class ProductInterestBloc
    extends Bloc<ProductInterestEvent, ProductInterestState> {
  ProductInterestBloc({required this.repository})
    : super(const ProductInterestState()) {
    on<LoadProductInterestRequested>(_load);
    on<UpdateProductInterestThresholdRequested>(_updateThreshold);
    on<CheckProductInactivityRequested>(_checkInactivity);
  }

  final CommercialRepository repository;

  Future<void> _load(
    LoadProductInterestRequested event,
    Emitter<ProductInterestState> emit,
  ) async {
    emit(const ProductInterestState(status: ProductInterestStatus.loading));
    try {
      final interest = await repository.getProductInterest(event.productId);
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: interest,
        ),
      );
    } on ProblemDetails catch (problem) {
      emit(
        ProductInterestState(
          status: ProductInterestStatus.failure,
          errorMessage: problem.userMessage,
        ),
      );
    } catch (_) {
      emit(
        const ProductInterestState(
          status: ProductInterestStatus.failure,
          errorMessage: 'No se pudieron cargar las estadísticas. Verifica tu sesión y que el producto te pertenezca.',
        ),
      );
    }
  }

  Future<void> _updateThreshold(
    UpdateProductInterestThresholdRequested event,
    Emitter<ProductInterestState> emit,
  ) async {
    final previous = state.interest;
    if (previous == null) return;
    emit(
      ProductInterestState(
        status: ProductInterestStatus.saving,
        interest: previous,
      ),
    );
    try {
      final interest = await repository.updateProductInterestThreshold(
        event.productId,
        event.threshold,
      );
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: interest,
          message: 'Umbral guardado correctamente.',
        ),
      );
    } on ProblemDetails catch (problem) {
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: previous,
          errorMessage: problem.userMessage,
        ),
      );
    } catch (_) {
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: previous,
          errorMessage: 'No se pudo guardar el umbral.',
        ),
      );
    }
  }

  Future<void> _checkInactivity(
    CheckProductInactivityRequested event,
    Emitter<ProductInterestState> emit,
  ) async {
    final previous = state.interest;
    if (previous == null) return;
    emit(
      ProductInterestState(
        status: ProductInterestStatus.checking,
        interest: previous,
      ),
    );
    try {
      await repository.checkProductInactivity(event.productId);
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: previous,
          message: 'Inactividad evaluada. Si corresponde una alerta, revisa tus notificaciones.',
        ),
      );
    } on ProblemDetails catch (problem) {
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: previous,
          errorMessage: problem.userMessage,
        ),
      );
    } catch (_) {
      emit(
        ProductInterestState(
          status: ProductInterestStatus.ready,
          interest: previous,
          errorMessage: 'No se pudo comprobar la inactividad.',
        ),
      );
    }
  }
}
