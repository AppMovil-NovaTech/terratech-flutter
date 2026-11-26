import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/core/errors/problem_details.dart';
import 'package:terratech_mobile/iam/domain/entities/auth_session.dart';
import 'package:terratech_mobile/iam/domain/entities/user_profile.dart';
import 'package:terratech_mobile/iam/domain/repositories/iam_repository.dart';
import 'package:terratech_mobile/iam/presentation/bloc/auth_bloc.dart';
import 'package:terratech_mobile/iam/presentation/bloc/auth_event.dart';
import 'package:terratech_mobile/iam/presentation/bloc/auth_state.dart';

class _StubIamRepository implements IamRepository {
  AuthSession? sessionToRestore;
  ProblemDetails? errorToThrow;
  bool signOutCalled = false;

  @override
  Future<AuthSession?> restoreSession() async => sessionToRestore;

  @override
  Future<AuthSession> signIn({
    required String emailAddress,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return AuthSession(
      userId: 3,
      emailAddress: emailAddress,
      fullName: 'Usuario Prueba',
      token: 'jwt-3',
    );
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return SignUpResult(
      userId: 4,
      emailAddress: emailAddress,
      fullName: fullName,
      emailVerificationRequired: false,
    );
  }

  @override
  Future<String> requestPasswordReset({required String emailAddress}) async =>
      'Correo enviado';

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {}

  @override
  Future<AuthSession> refreshCurrentUser() async =>
      const AuthSession(
        userId: 3,
        emailAddress: 'u@terratech.pe',
        fullName: 'U',
        token: 't',
      );

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }

  @override
  Future<UserProfile?> getMyProfile() async => null;

  @override
  Future<UserProfile> upsertMyProfile(UpsertUserProfileInput input) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AuthBloc', () {
    late _StubIamRepository repo;
    late AuthBloc bloc;

    setUp(() {
      repo = _StubIamRepository();
      bloc = AuthBloc(repository: repo);
    });

    tearDown(() => bloc.close());

    test('AuthSignUpRequested emits prefilled credentials without logging in', () async {
      bloc.add(
        const AuthSignUpRequested(
          fullName: 'Angel Pariona',
          emailAddress: 'angel@terratech.pe',
          password: 'Password123',
          confirmPassword: 'Password123',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.lastAction, 'lastAction', AuthActionType.signUp)
              .having((s) => s.registeredEmail, 'registeredEmail', 'angel@terratech.pe')
              .having((s) => s.registeredPassword, 'registeredPassword', 'Password123'),
        ),
      );
    });

    test('AuthSignInRequested emits authenticated state and clears errors', () async {
      bloc.add(
        const AuthSignInRequested(
          emailAddress: 'angel@terratech.pe',
          password: 'Password123',
        ),
      );

      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.authenticated)
              .having((s) => s.session?.userId, 'userId', 3),
        ),
      );
    });

    test('AuthSessionExpired signs out and emits unauthenticated notice', () async {
      bloc.add(
        const AuthSignInRequested(
          emailAddress: 'angel@terratech.pe',
          password: 'Password123',
        ),
      );
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>().having((s) => s.isAuthenticated, 'auth', isTrue),
        ),
      );

      bloc.add(const AuthSessionExpired());
      await expectLater(
        bloc.stream,
        emitsThrough(
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.unauthenticated)
              .having((s) => s.infoMessage, 'info', contains('expirado')),
        ),
      );
      expect(repo.signOutCalled, isTrue);
    });
  });
}
