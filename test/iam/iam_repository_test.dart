import 'package:flutter_test/flutter_test.dart';
import 'package:terratech_mobile/core/errors/problem_details.dart';
import 'package:terratech_mobile/core/storage/secure_storage.dart';
import 'package:terratech_mobile/iam/data/datasources/auth_session_local_datasource.dart';
import 'package:terratech_mobile/iam/data/datasources/iam_remote_datasource.dart';
import 'package:terratech_mobile/iam/data/models/authenticated_user_model.dart';
import 'package:terratech_mobile/iam/data/models/user_profile_model.dart';
import 'package:terratech_mobile/iam/data/repositories/iam_repository_impl.dart';
import 'package:terratech_mobile/iam/domain/entities/user_profile.dart';

class _InMemorySecureStorage implements SecureStorage {
  final Map<String, String> _store = <String, String>{};
  static const String _tokenKey = 'jwt';

  @override
  Future<void> clearAll() async => _store.clear();

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<void> deleteToken() async => _store.remove(_tokenKey);

  @override
  Future<String?> getToken() async => _store[_tokenKey];

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> saveToken(String token) async => _store[_tokenKey] = token;

  @override
  Future<void> write({required String key, required String value}) async =>
      _store[key] = value;
}

class _FakeIamRemoteDataSource implements IamRemoteDataSource {
  AuthenticatedUserModel? signInResponse;
  AuthenticatedUserModel? signUpResponse;
  UserProfileModel? profileResponse;
  ProblemDetails? errorToThrow;

  @override
  Future<AuthenticatedUserModel> signIn({
    required String emailAddress,
    required String password,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return signInResponse!;
  }

  @override
  Future<AuthenticatedUserModel> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return signUpResponse!;
  }

  @override
  Future<String> requestPasswordReset({required String emailAddress}) async {
    if (errorToThrow != null) throw errorToThrow!;
    return 'Revisa tu correo para restablecer tu contraseña.';
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
  }

  @override
  Future<AuthenticatedUserModel> getCurrentUser() async {
    if (errorToThrow != null) throw errorToThrow!;
    return signInResponse!;
  }

  @override
  Future<UserProfileModel?> getMyProfile() async {
    if (errorToThrow != null) throw errorToThrow!;
    return profileResponse;
  }

  @override
  Future<UserProfileModel> upsertMyProfile(UpsertUserProfileInput input) async {
    if (errorToThrow != null) throw errorToThrow!;
    return UserProfileModel(
      id: 10,
      userId: 5,
      fullName: input.fullName,
      emailAddress: 'campo@terratech.pe',
      fundoName: input.fundoName,
      contactPhone: input.contactPhone,
      location: input.location,
      sizeM2: input.sizeM2,
      moistureThreshold: input.moistureThreshold ?? 30.0,
      tempThreshold: input.tempThreshold ?? 28.0,
    );
  }
}

void main() {
  group('IamRepositoryImpl', () {
    late _InMemorySecureStorage storage;
    late AuthSessionLocalDataSource local;
    late _FakeIamRemoteDataSource remote;
    late IamRepositoryImpl repository;

    setUp(() {
      storage = _InMemorySecureStorage();
      local = AuthSessionLocalDataSource(secureStorage: storage);
      remote = _FakeIamRemoteDataSource();
      repository = IamRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );
    });

    test('signIn persists session and restoreSession recovers it', () async {
      remote.signInResponse = AuthenticatedUserModel(
        id: 12,
        emailAddress: 'angel@terratech.pe',
        fullName: 'Angel Pariona',
        token: 'jwt-abc',
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 4)),
      );

      final session = await repository.signIn(
        emailAddress: 'angel@terratech.pe',
        password: 'secret123',
      );
      expect(session.userId, 12);
      expect(session.token, 'jwt-abc');

      final restored = await repository.restoreSession();
      expect(restored, equals(session));
      expect(await storage.read('us29_authenticated_user_id'), '12');
    });

    test('restoreSession clears and returns null when token expired', () async {
      remote.signInResponse = AuthenticatedUserModel(
        id: 12,
        emailAddress: 'angel@terratech.pe',
        fullName: 'Angel Pariona',
        token: 'expired-jwt',
        expiresAt: DateTime.now().toUtc().subtract(const Duration(minutes: 5)),
      );

      await repository.signIn(
        emailAddress: 'angel@terratech.pe',
        password: 'secret123',
      );

      final restored = await repository.restoreSession();
      expect(restored, isNull);
      expect(await storage.getToken(), isNull);
    });

    test('translates EMAIL_EXISTS ProblemDetails into Spanish copy', () async {
      remote.errorToThrow = const ProblemDetails(
        title: 'Email exists',
        status: 409,
        detail: 'Email is already registered.',
        extensions: <String, dynamic>{'code': 'EMAIL_EXISTS'},
      );

      await expectLater(
        () => repository.signUp(
          fullName: 'Angel',
          emailAddress: 'dup@terratech.pe',
          password: 'password123',
          confirmPassword: 'password123',
        ),
        throwsA(
          isA<ProblemDetails>().having(
            (e) => e.userMessage,
            'userMessage',
            contains('ya está registrado'),
          ),
        ),
      );
    });

    test('upsertMyProfile updates fullName in stored AuthSession', () async {
      remote.signInResponse = AuthenticatedUserModel(
        id: 5,
        emailAddress: 'campo@terratech.pe',
        fullName: 'Nombre Inicial',
        token: 'jwt-5',
        expiresAt: DateTime.now().toUtc().add(const Duration(hours: 2)),
      );
      await repository.signIn(
        emailAddress: 'campo@terratech.pe',
        password: 'password123',
      );

      final saved = await repository.upsertMyProfile(
        const UpsertUserProfileInput(
          fullName: 'Nombre Actualizado',
          fundoName: 'Fundo Los Olivos',
          contactPhone: '+51 999111222',
          location: 'Huánuco',
          sizeM2: 15000,
        ),
      );

      expect(saved.fullName, 'Nombre Actualizado');
      final restored = await repository.restoreSession();
      expect(restored?.fullName, 'Nombre Actualizado');
    });
  });
}
