import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/core/theme/app_theme.dart';
import 'package:terratech_mobile/iam/domain/entities/auth_session.dart';
import 'package:terratech_mobile/iam/domain/entities/user_profile.dart';
import 'package:terratech_mobile/iam/domain/repositories/iam_repository.dart';
import 'package:terratech_mobile/iam/presentation/bloc/auth_bloc.dart';
import 'package:terratech_mobile/iam/presentation/screens/profile_screen.dart';
import 'package:terratech_mobile/iam/presentation/screens/sign_in_screen.dart';
import 'package:terratech_mobile/iam/presentation/screens/sign_up_screen.dart';
import 'package:terratech_mobile/iam/presentation/screens/terms_and_conditions_screen.dart';

class _FakeIamRepo implements IamRepository {
  UserProfile? storedProfile;

  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthSession> signIn({
    required String emailAddress,
    required String password,
  }) async {
    return AuthSession(
      userId: 9,
      emailAddress: emailAddress,
      fullName: 'Angel Pariona',
      token: 'token-9',
    );
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    return SignUpResult(
      userId: 9,
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
        userId: 9,
        emailAddress: 'angel@terratech.pe',
        fullName: 'Angel Pariona',
        token: 'token-9',
      );

  @override
  Future<void> signOut() async {}

  @override
  Future<UserProfile?> getMyProfile() async => storedProfile;

  @override
  Future<UserProfile> upsertMyProfile(UpsertUserProfileInput input) async {
    return UserProfile(
      id: 1,
      userId: 9,
      fullName: input.fullName,
      emailAddress: 'angel@terratech.pe',
      fundoName: input.fundoName,
      contactPhone: input.contactPhone,
      location: input.location,
      sizeM2: input.sizeM2,
      moistureThreshold: input.moistureThreshold ?? 35,
      tempThreshold: input.tempThreshold ?? 25,
    );
  }
}

void main() {
  group('IAM Widget Tests', () {
    testWidgets(
      'SignUp button stays disabled until Terms and Conditions are accepted, then redirects to prefilled SignIn',
      (tester) async {
        final repo = _FakeIamRepo();
        final authBloc = AuthBloc(repository: repo);
        addTearDown(authBloc.close);

        await tester.pumpWidget(
          BlocProvider<AuthBloc>.value(
            value: authBloc,
            child: MaterialApp(
              theme: AppTheme.light(),
              home: const SignUpScreen(),
            ),
          ),
        );

        final submitFinder = find.byKey(const Key('sign_up_submit_button'));
        expect(tester.widget<FilledButton>(submitFinder).onPressed, isNull);

        await tester.enterText(
          find.byKey(const Key('sign_up_full_name_field')),
          'Angel Pariona',
        );
        await tester.enterText(
          find.byKey(const Key('sign_up_email_field')),
          'angel@terratech.pe',
        );
        await tester.enterText(
          find.byKey(const Key('sign_up_password_field')),
          'Secret123',
        );
        await tester.enterText(
          find.byKey(const Key('sign_up_confirm_password_field')),
          'Secret123',
        );

        // Open Terms and Conditions screen and accept them.
        await tester.ensureVisible(
          find.byKey(const Key('sign_up_read_terms_button')),
        );
        await tester.tap(find.byKey(const Key('sign_up_read_terms_button')));
        await tester.pumpAndSettle();

        expect(find.byType(TermsAndConditionsScreen), findsOneWidget);
        expect(
          find.text('1. Objeto y aceptación de las condiciones'),
          findsOneWidget,
        );

        await tester.tap(find.byKey(const Key('terms_accept_button')));
        await tester.pumpAndSettle();

        // Button must now be enabled.
        expect(tester.widget<FilledButton>(submitFinder).onPressed, isNotNull);

        await tester.ensureVisible(submitFinder);
        await tester.tap(submitFinder);
        await tester.pumpAndSettle();

        // Redirected to SignInScreen with prefilled email & password.
        expect(find.byType(SignInScreen), findsOneWidget);
        expect(find.text('angel@terratech.pe'), findsOneWidget);
        expect(find.text('Secret123'), findsOneWidget);
        expect(find.byKey(const Key('sign_in_info_banner')), findsOneWidget);
      },
    );

    testWidgets('ProfileScreen validates positive terrain size', (
      tester,
    ) async {
      final repo = _FakeIamRepo();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ProfileScreen(repository: repo),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('profile_full_name_field')),
        'Angel Pariona',
      );
      await tester.enterText(
        find.byKey(const Key('profile_fundo_name_field')),
        'Fundo San Juan',
      );
      await tester.enterText(
        find.byKey(const Key('profile_phone_field')),
        '+51 999888777',
      );
      await tester.enterText(
        find.byKey(const Key('profile_location_field')),
        'Huánuco',
      );
      await tester.enterText(
        find.byKey(const Key('profile_size_m2_field')),
        '-5',
      );

      final saveButton = find.byKey(const Key('profile_save_button'));
      await tester.ensureVisible(saveButton);
      await tester.tap(saveButton);
      await tester.pump();

      expect(
        find.text('El tamaño del terreno debe ser mayor a 0.'),
        findsOneWidget,
      );
    });
  });
}
