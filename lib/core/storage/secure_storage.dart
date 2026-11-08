import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract contract for storing and retrieving the JWT token and sensitive
/// local session data.
///
/// Keeping this as an interface decouples the networking layer and the
/// Commercial/Community bounded contexts from any specific storage plugin.
abstract interface class SecureStorage {
  /// Retrieves the stored JWT access token, or `null` if no session is active.
  Future<String?> getToken();

  /// Persists the JWT access token securely.
  Future<void> saveToken(String token);

  /// Removes the stored JWT access token.
  Future<void> deleteToken();

  /// Reads an arbitrary sensitive session value by [key].
  Future<String?> read(String key);

  /// Writes an arbitrary sensitive session [value] under [key].
  Future<void> write({required String key, required String value});

  /// Deletes a specific key from secure storage.
  Future<void> delete(String key);

  /// Clears all stored credentials and sensitive session data.
  Future<void> clearAll();
}

/// Default implementation of [SecureStorage] backed by [FlutterSecureStorage].
class FlutterSecureStorageImpl implements SecureStorage {
  FlutterSecureStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
          );

  static const String _jwtTokenKey = 'auth_jwt_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> getToken() => _storage.read(key: _jwtTokenKey);

  @override
  Future<void> saveToken(String token) =>
      _storage.write(key: _jwtTokenKey, value: token);

  @override
  Future<void> deleteToken() => _storage.delete(key: _jwtTokenKey);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write({required String key, required String value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
