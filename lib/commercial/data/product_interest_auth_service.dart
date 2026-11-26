import 'package:dio/dio.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage.dart';

/// Authentication for the supplier-only US29 dashboard.
/// Reuses the app-wide Dio interceptor and secure token storage.
class ProductInterestAuthService {
  ProductInterestAuthService({
    required DioClient dioClient,
    required SecureStorage secureStorage,
  }) : _dio = dioClient.dio,
       _storage = secureStorage;

  static const String _realUserIdKey = 'us29_authenticated_user_id';
  static const String _userEmailKey = 'auth_user_email';
  static const String _userNameKey = 'auth_user_full_name';

  final Dio _dio;
  final SecureStorage _storage;

  Future<int?> currentUserId() async {
    final token = await _storage.getToken();
    if (token == null || token.trim().isEmpty) return null;
    final stored = await _storage.read(_realUserIdKey);
    final id = int.tryParse(stored ?? '');
    return id != null && id > 0 ? id : null;
  }

  Future<String?> currentEmail() => _storage.read(_userEmailKey);

  Future<int> signIn({required String email, required String password}) async {
    final response = await _dio.post<dynamic>(
      '/api/v1/authentication/sign-in',
      data: <String, String>{
        'emailAddress': email.trim(),
        'password': password,
      },
    );
    final data = response.data;
    if (data is! Map) {
      throw const FormatException('Unexpected authentication response');
    }
    final userIdValue = data['id'];
    final userId = userIdValue is int
        ? userIdValue
        : int.tryParse(userIdValue?.toString() ?? '');
    final tokenValue = data['token'];
    if (userId == null ||
        userId <= 0 ||
        tokenValue is! String ||
        tokenValue.trim().isEmpty) {
      throw const FormatException('Invalid authentication response');
    }
    await _storage.saveToken(tokenValue);
    await _storage.write(key: _realUserIdKey, value: userId.toString());
    await _storage.write(key: _userEmailKey, value: email.trim());
    await _storage.write(key: _userNameKey, value: email.trim());
    return userId;
  }

  Future<void> signOut() async {
    await _storage.deleteToken();
    await _storage.delete(_realUserIdKey);
    await _storage.delete(_userEmailKey);
    await _storage.delete(_userNameKey);
  }
}
