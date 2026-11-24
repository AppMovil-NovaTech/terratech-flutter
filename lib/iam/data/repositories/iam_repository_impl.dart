import '../../../core/errors/problem_details.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/iam_repository.dart';
import '../datasources/auth_session_local_datasource.dart';
import '../datasources/iam_remote_datasource.dart';

/// Repository coordinating remote IAM calls, secure session persistence, and
/// Spanish user-friendly error mapping from RFC 7807 [ProblemDetails].
class IamRepositoryImpl implements IamRepository {
  IamRepositoryImpl({
    required IamRemoteDataSource remoteDataSource,
    required AuthSessionLocalDataSource localDataSource,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final IamRemoteDataSource _remote;
  final AuthSessionLocalDataSource _local;

  @override
  Future<AuthSession?> restoreSession() async {
    final stored = await _local.readSession();
    if (stored == null) return null;
    if (stored.isExpired) {
      await _local.clearSession();
      return null;
    }
    return stored;
  }

  @override
  Future<AuthSession> signIn({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final model = await _remote.signIn(
        emailAddress: emailAddress,
        password: password,
      );
      final session = model.toSession();
      await _local.saveSession(session);
      return session;
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    } on FormatException catch (e) {
      throw ProblemDetails(
        title: 'Respuesta inválida',
        status: 500,
        detail: e.message,
      );
    }
  }

  @override
  Future<SignUpResult> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final model = await _remote.signUp(
        fullName: fullName,
        emailAddress: emailAddress,
        password: password,
        confirmPassword: confirmPassword,
      );
      return model.toSignUpResult();
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  @override
  Future<String> requestPasswordReset({required String emailAddress}) async {
    try {
      return await _remote.requestPasswordReset(emailAddress: emailAddress);
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _remote.resetPassword(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  @override
  Future<AuthSession> refreshCurrentUser() async {
    final stored = await _local.readSession();
    if (stored == null) {
      throw const ProblemDetails(
        title: 'Sesión no iniciada',
        status: 401,
        detail: 'Inicia sesión para consultar tus datos de usuario.',
      );
    }
    try {
      final model = await _remote.getCurrentUser();
      final updated = stored.copyWith(
        userId: model.id > 0 ? model.id : stored.userId,
        emailAddress: model.emailAddress.isNotEmpty
            ? model.emailAddress
            : stored.emailAddress,
        fullName: model.fullName.isNotEmpty ? model.fullName : stored.fullName,
      );
      await _local.saveSession(updated);
      return updated;
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  @override
  Future<void> signOut() => _local.clearSession();

  @override
  Future<UserProfile?> getMyProfile() async {
    try {
      return await _remote.getMyProfile();
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  @override
  Future<UserProfile> upsertMyProfile(UpsertUserProfileInput input) async {
    try {
      final profile = await _remote.upsertMyProfile(input);
      final stored = await _local.readSession();
      if (stored != null && profile.fullName.trim().isNotEmpty) {
        await _local.saveSession(
          stored.copyWith(fullName: profile.fullName.trim()),
        );
      }
      return profile;
    } on ProblemDetails catch (problem) {
      throw _translateProblem(problem);
    }
  }

  ProblemDetails _translateProblem(ProblemDetails problem) {
    final code = (problem.extensions['code'] as String?)?.toUpperCase() ?? '';
    final detail = switch (code) {
      'INVALID_CREDENTIALS' => 'Credenciales inválidas. Intente nuevamente.',
      'EMAIL_EXISTS' =>
        'Este correo ya está registrado. Inicia sesión o recupera tu contraseña.',
      'PASSWORD_CONFIRMATION_MISMATCH' => 'Las contraseñas no coinciden.',
      'INVALID_NAME' => 'El nombre requiere al menos 2 caracteres.',
      'INVALID_PASSWORD' => 'La contraseña debe tener entre 6 y 128 caracteres.',
      'TOKEN_INVALID_OR_EXPIRED' =>
        'El enlace o token ha expirado o es inválido. Solicita uno nuevo.',
      'UNAUTHENTICATED' =>
        'Tu sesión ha expirado o requiere autenticación. Inicia sesión nuevamente.',
      _ => switch (problem.status) {
        401 => 'Credenciales inválidas o sesión expirada.',
        409 =>
          'Este correo ya está registrado. Inicia sesión o recupera tu contraseña.',
        503 =>
          'El servicio de correo no está disponible en este momento. Intenta más tarde.',
        _ => problem.userMessage,
      },
    };

    return ProblemDetails(
      type: problem.type,
      title: problem.title,
      status: problem.status,
      detail: detail,
      instance: problem.instance,
      extensions: problem.extensions,
    );
  }
}
