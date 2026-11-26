import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => const <Object?>[];
}

final class AuthRestoreRequested extends AuthEvent {
  const AuthRestoreRequested();
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({
    required this.emailAddress,
    required this.password,
  });

  final String emailAddress;
  final String password;

  @override
  List<Object?> get props => <Object?>[emailAddress, password];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.fullName,
    required this.emailAddress,
    required this.password,
    required this.confirmPassword,
  });

  final String fullName;
  final String emailAddress;
  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => <Object?>[
    fullName,
    emailAddress,
    password,
    confirmPassword,
  ];
}

final class AuthPasswordResetRequested extends AuthEvent {
  const AuthPasswordResetRequested({required this.emailAddress});

  final String emailAddress;

  @override
  List<Object?> get props => <Object?>[emailAddress];
}

final class AuthPasswordResetConfirmed extends AuthEvent {
  const AuthPasswordResetConfirmed({
    required this.token,
    required this.password,
    required this.confirmPassword,
  });

  final String token;
  final String password;
  final String confirmPassword;

  @override
  List<Object?> get props => <Object?>[token, password, confirmPassword];
}

final class AuthSessionUpdated extends AuthEvent {
  const AuthSessionUpdated(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => <Object?>[session];
}

final class AuthSessionExpired extends AuthEvent {
  const AuthSessionExpired();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

final class AuthFeedbackCleared extends AuthEvent {
  const AuthFeedbackCleared();
}
