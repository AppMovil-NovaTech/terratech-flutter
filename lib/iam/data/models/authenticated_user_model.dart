import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/iam_repository.dart';

/// Data transfer model for `/api/v1/authentication/sign-in` and `/sign-up` responses.
class AuthenticatedUserModel {
  const AuthenticatedUserModel({
    required this.id,
    required this.emailAddress,
    required this.fullName,
    this.token,
    this.expiresAt,
    this.emailVerificationRequired = false,
  });

  final int id;
  final String emailAddress;
  final String fullName;
  final String? token;
  final DateTime? expiresAt;
  final bool emailVerificationRequired;

  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    final rawExpiresAt = json['expiresAt'];
    final parsedExpiresAt = rawExpiresAt is String
        ? DateTime.tryParse(rawExpiresAt)
        : null;

    return AuthenticatedUserModel(
      id: parsedId,
      emailAddress: (json['emailAddress'] as String?)?.trim() ?? '',
      fullName: (json['fullName'] as String?)?.trim() ?? '',
      token: (json['token'] as String?)?.trim(),
      expiresAt: parsedExpiresAt,
      emailVerificationRequired: json['emailVerificationRequired'] == true,
    );
  }

  AuthSession toSession() {
    final jwt = token;
    if (id <= 0 || jwt == null || jwt.isEmpty) {
      throw const FormatException('La respuesta de autenticación no contiene un token válido.');
    }
    return AuthSession(
      userId: id,
      emailAddress: emailAddress,
      fullName: fullName,
      token: jwt,
      expiresAt: expiresAt,
    );
  }

  SignUpResult toSignUpResult() {
    if (id <= 0) {
      throw const FormatException('La respuesta de registro no es válida.');
    }
    return SignUpResult(
      userId: id,
      emailAddress: emailAddress,
      fullName: fullName,
      emailVerificationRequired: emailVerificationRequired,
    );
  }
}
