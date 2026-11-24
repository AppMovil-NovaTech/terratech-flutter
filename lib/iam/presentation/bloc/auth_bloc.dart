import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/problem_details.dart';
import '../../domain/repositories/iam_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Global authentication BLoC managing session lifecycle and IAM actions.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required IamRepository repository})
    : _repository = repository,
      super(const AuthState()) {
    on<AuthRestoreRequested>(_onRestore);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthPasswordResetRequested>(_onRequestPasswordReset);
    on<AuthPasswordResetConfirmed>(_onResetPassword);
    on<AuthSessionUpdated>(_onSessionUpdated);
    on<AuthSessionExpired>(_onSessionExpired);
    on<AuthSignOutRequested>(_onSignOut);
    on<AuthFeedbackCleared>(_onFeedbackCleared);
  }

  final IamRepository _repository;

  Future<void> _onRestore(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));
    try {
      final restored = await _repository.restoreSession();
      if (restored != null) {
        emit(
          state.copyWith(
            status: AuthStatus.authenticated,
            session: restored,
            clearError: true,
            clearInfo: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            status: AuthStatus.unauthenticated,
            clearSession: true,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          clearSession: true,
        ),
      );
    }
  }

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isBusy: true,
        lastAction: AuthActionType.signIn,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final session = await _repository.signIn(
        emailAddress: event.emailAddress,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          session: session,
          isBusy: false,
          lastAction: AuthActionType.signIn,
          clearError: true,
          clearInfo: true,
          clearRegisteredCredentials: true,
        ),
      );
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isBusy: false,
          lastAction: AuthActionType.signIn,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isBusy: false,
          lastAction: AuthActionType.signIn,
          errorMessage: 'No se pudo iniciar sesión. Intenta nuevamente.',
        ),
      );
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isBusy: true,
        lastAction: AuthActionType.signUp,
        clearError: true,
        clearInfo: true,
        clearRegisteredCredentials: true,
      ),
    );
    try {
      final result = await _repository.signUp(
        fullName: event.fullName,
        emailAddress: event.emailAddress,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isBusy: false,
          lastAction: AuthActionType.signUp,
          infoMessage:
              'Cuenta creada para ${result.emailAddress}. Inicia sesión para continuar.',
          registeredEmail: result.emailAddress,
          registeredPassword: event.password,
        ),
      );
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isBusy: false,
          lastAction: AuthActionType.signUp,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          isBusy: false,
          lastAction: AuthActionType.signUp,
          errorMessage: 'No se pudo completar el registro. Intenta nuevamente.',
        ),
      );
    }
  }

  Future<void> _onRequestPasswordReset(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isBusy: true,
        lastAction: AuthActionType.passwordResetRequest,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      final message = await _repository.requestPasswordReset(
        emailAddress: event.emailAddress,
      );
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetRequest,
          infoMessage: message,
        ),
      );
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetRequest,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetRequest,
          errorMessage:
              'No se pudo enviar la solicitud de recuperación. Intenta más tarde.',
        ),
      );
    }
  }

  Future<void> _onResetPassword(
    AuthPasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        isBusy: true,
        lastAction: AuthActionType.passwordResetConfirm,
        clearError: true,
        clearInfo: true,
      ),
    );
    try {
      await _repository.resetPassword(
        token: event.token,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetConfirm,
          infoMessage: 'Contraseña actualizada. Inicia sesión.',
        ),
      );
    } on ProblemDetails catch (error) {
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetConfirm,
          errorMessage: error.userMessage,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isBusy: false,
          lastAction: AuthActionType.passwordResetConfirm,
          errorMessage: 'No se pudo restablecer la contraseña.',
        ),
      );
    }
  }

  void _onSessionUpdated(AuthSessionUpdated event, Emitter<AuthState> emit) {
    if (state.status == AuthStatus.authenticated) {
      emit(state.copyWith(session: event.session));
    }
  }

  Future<void> _onSessionExpired(
    AuthSessionExpired event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status == AuthStatus.unauthenticated && !state.isAuthenticated) {
      return;
    }
    await _repository.signOut();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        lastAction: AuthActionType.signOut,
        infoMessage: 'Tu sesión ha expirado. Inicia sesión nuevamente.',
      ),
    );
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isBusy: true, clearError: true, clearInfo: true));
    await _repository.signOut();
    emit(
      const AuthState(
        status: AuthStatus.unauthenticated,
        lastAction: AuthActionType.signOut,
      ),
    );
  }

  void _onFeedbackCleared(AuthFeedbackCleared event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        lastAction: AuthActionType.none,
        clearError: true,
        clearInfo: true,
        clearRegisteredCredentials: true,
      ),
    );
  }
}
