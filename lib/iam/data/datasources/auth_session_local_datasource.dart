import '../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_session.dart';

/// Persists and restores the unified app authentication session in [SecureStorage].
class AuthSessionLocalDataSource {
  AuthSessionLocalDataSource({required SecureStorage secureStorage})
    : _storage = secureStorage;

  static const String userIdKey = 'auth_user_id';
  static const String userEmailKey = 'auth_user_email';
  static const String userNameKey = 'auth_user_full_name';
  static const String expiresAtKey = 'auth_token_expires_at';
  static const String legacyUs29UserIdKey = 'us29_authenticated_user_id';

  final SecureStorage _storage;

  Future<void> saveSession(AuthSession session) async {
    await _storage.saveToken(session.token);
    await _storage.write(key: userIdKey, value: session.userId.toString());
    await _storage.write(key: legacyUs29UserIdKey, value: session.userId.toString());
    await _storage.write(key: userEmailKey, value: session.emailAddress);
    await _storage.write(key: userNameKey, value: session.displayName);
    if (session.expiresAt != null) {
      await _storage.write(
        key: expiresAtKey,
        value: session.expiresAt!.toUtc().toIso8601String(),
      );
    } else {
      await _storage.delete(expiresAtKey);
    }
  }

  Future<AuthSession?> readSession() async {
    try {
      final token = await _storage.getToken();
      if (token == null || token.trim().isEmpty) {
        return null;
      }

      final rawUserId =
          await _storage.read(userIdKey) ??
          await _storage.read(legacyUs29UserIdKey);
      final userId = int.tryParse(rawUserId ?? '');
      final email = (await _storage.read(userEmailKey))?.trim() ?? '';
      final fullName = (await _storage.read(userNameKey))?.trim() ?? '';
      final rawExpires = await _storage.read(expiresAtKey);
      final expiresAt = rawExpires != null ? DateTime.tryParse(rawExpires) : null;

      if (userId == null || userId <= 0 || email.isEmpty) {
        return null;
      }

      return AuthSession(
        userId: userId,
        emailAddress: email,
        fullName: fullName.isNotEmpty ? fullName : email,
        token: token.trim(),
        expiresAt: expiresAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _storage.deleteToken();
    await _storage.delete(userIdKey);
    await _storage.delete(legacyUs29UserIdKey);
    await _storage.delete(userEmailKey);
    await _storage.delete(userNameKey);
    await _storage.delete(expiresAtKey);
  }
}
