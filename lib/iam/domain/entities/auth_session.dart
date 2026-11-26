import 'package:equatable/equatable.dart';

/// Authenticated user session backed by the backend JWT authentication response.
class AuthSession extends Equatable {
  const AuthSession({
    required this.userId,
    required this.emailAddress,
    required this.fullName,
    required this.token,
    this.expiresAt,
  });

  final int userId;
  final String emailAddress;
  final String fullName;
  final String token;
  final DateTime? expiresAt;

  /// Returns `true` if [expiresAt] is known and already in the past (UTC).
  bool get isExpired {
    final expiry = expiresAt;
    if (expiry == null) return false;
    return DateTime.now().toUtc().isAfter(expiry.toUtc());
  }

  /// Display name falling back to [emailAddress] when [fullName] is blank.
  String get displayName =>
      fullName.trim().isNotEmpty ? fullName.trim() : emailAddress;

  AuthSession copyWith({
    int? userId,
    String? emailAddress,
    String? fullName,
    String? token,
    DateTime? expiresAt,
  }) {
    return AuthSession(
      userId: userId ?? this.userId,
      emailAddress: emailAddress ?? this.emailAddress,
      fullName: fullName ?? this.fullName,
      token: token ?? this.token,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    userId,
    emailAddress,
    fullName,
    token,
    expiresAt,
  ];
}
