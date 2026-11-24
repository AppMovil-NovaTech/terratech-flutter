import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/problem_details.dart';
import '../../domain/repositories/iam_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

/// BLoC managing `/api/v1/profiles/me` (US09 & prerequisite for US31/US32 alerts).
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required IamRepository repository})
    : _repository = repository,
      super(const ProfileState()) {
    on<LoadMyProfileRequested>(_onLoad);
    on<SaveMyProfileRequested>(_onSave);
  }

  final IamRepository _repository;

  Future<void> _onLoad(
    LoadMyProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final profile = await _repository.getMyProfile();
      if (profile == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.empty,
            clearProfile: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: ProfileStatus.loaded,
            profile: profile,
          ),
        );
      }
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: 'No se pudo cargar tu perfil agrícola.',
        ),
      );
    }
  }

  Future<void> _onSave(
    SaveMyProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        isSaving: true,
        clearError: true,
        clearSuccess: true,
      ),
    );
    try {
      final saved = await _repository.upsertMyProfile(event.input);
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: saved,
          isSaving: false,
          successMessage: 'Perfil actualizado correctamente.',
        ),
      );
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSaving: false,
          errorMessage: 'No se pudo guardar el perfil. Intenta nuevamente.',
        ),
      );
    }
  }
}
