import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

enum AuthActionType {
  none,
  signIn,
  signUp,
  passwordResetRequest,
  passwordResetConfirm,
  signOut,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.isBusy = false,
    this.lastAction = AuthActionType.none,
    this.errorMessage,
    this.infoMessage,
    this.registeredEmail,
    this.registeredPassword,
  });

  final AuthStatus status;
  final AuthSession? session;
  final bool isBusy;
  final AuthActionType lastAction;
  final String? errorMessage;
  final String? infoMessage;
  final String? registeredEmail;
  final String? registeredPassword;

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && session != null;

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    bool clearSession = false,
    bool? isBusy,
    AuthActionType? lastAction,
    String? errorMessage,
    bool clearError = false,
    String? infoMessage,
    bool clearInfo = false,
    String? registeredEmail,
    String? registeredPassword,
    bool clearRegisteredCredentials = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : (session ?? this.session),
      isBusy: isBusy ?? this.isBusy,
      lastAction: lastAction ?? this.lastAction,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
      registeredEmail: clearRegisteredCredentials
          ? null
          : (registeredEmail ?? this.registeredEmail),
      registeredPassword: clearRegisteredCredentials
          ? null
          : (registeredPassword ?? this.registeredPassword),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    session,
    isBusy,
    lastAction,
    errorMessage,
    infoMessage,
    registeredEmail,
    registeredPassword,
  ];
}
