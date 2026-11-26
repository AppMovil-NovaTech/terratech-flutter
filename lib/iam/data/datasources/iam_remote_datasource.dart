import 'package:dio/dio.dart';

import '../../../core/errors/problem_details.dart';
import '../../../core/network/dio_client.dart';
import '../../domain/entities/user_profile.dart';
import '../models/authenticated_user_model.dart';
import '../models/user_profile_model.dart';

/// Contract for remote HTTP operations against TerraTech IAM and Profile APIs.
abstract interface class IamRemoteDataSource {
  Future<AuthenticatedUserModel> signIn({
    required String emailAddress,
    required String password,
  });

  Future<AuthenticatedUserModel> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  });

  Future<String> requestPasswordReset({required String emailAddress});

  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  });

  Future<AuthenticatedUserModel> getCurrentUser();

  Future<UserProfileModel?> getMyProfile();

  Future<UserProfileModel> upsertMyProfile(UpsertUserProfileInput input);
}

/// Implementation of [IamRemoteDataSource] backed by [DioClient].
class IamRemoteDataSourceImpl implements IamRemoteDataSource {
  IamRemoteDataSourceImpl({required DioClient dioClient})
    : _dio = dioClient.dio;

  static const String signInEndpoint = '/api/v1/authentication/sign-in';
  static const String signUpEndpoint = '/api/v1/authentication/sign-up';
  static const String passwordResetRequestEndpoint =
      '/api/v1/authentication/password-reset-requests';
  static const String passwordResetEndpoint =
      '/api/v1/authentication/password-resets';
  static const String usersMeEndpoint = '/api/v1/users/me';
  static const String myProfileEndpoint = '/api/v1/profiles/me';

  final Dio _dio;

  @override
  Future<AuthenticatedUserModel> signIn({
    required String emailAddress,
    required String password,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        signInEndpoint,
        data: <String, String>{
          'emailAddress': emailAddress.trim(),
          'password': password,
        },
      );
      return AuthenticatedUserModel.fromJson(_requireMap(response.data));
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<AuthenticatedUserModel> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post<dynamic>(
        signUpEndpoint,
        data: <String, String>{
          'fullName': fullName.trim(),
          'emailAddress': emailAddress.trim(),
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
      return AuthenticatedUserModel.fromJson(_requireMap(response.data));
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<String> requestPasswordReset({required String emailAddress}) async {
    try {
      final response = await _dio.post<dynamic>(
        passwordResetRequestEndpoint,
        data: <String, String>{'emailAddress': emailAddress.trim()},
      );
      final map = _extractMap(response.data);
      final message = (map?['message'] as String?)?.trim();
      return (message != null && message.isNotEmpty)
          ? message
          : 'Si la cuenta existe, enviaremos un enlace de recuperación a tu correo.';
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      await _dio.post<void>(
        passwordResetEndpoint,
        data: <String, String>{
          'token': token.trim(),
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<AuthenticatedUserModel> getCurrentUser() async {
    try {
      final response = await _dio.get<dynamic>(usersMeEndpoint);
      return AuthenticatedUserModel.fromJson(_requireMap(response.data));
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  @override
  Future<UserProfileModel?> getMyProfile() async {
    try {
      final response = await _dio.get<dynamic>(myProfileEndpoint);
      final map = _extractMap(response.data);
      return map == null ? null : UserProfileModel.fromJson(map);
    } on DioException catch (e) {
      final problem = _extractProblemDetails(e);
      if (problem.status == 404) {
        return null;
      }
      throw problem;
    }
  }

  @override
  Future<UserProfileModel> upsertMyProfile(UpsertUserProfileInput input) async {
    try {
      final response = await _dio.put<dynamic>(
        myProfileEndpoint,
        data: UserProfileModel.toUpsertJson(input),
      );
      return UserProfileModel.fromJson(_requireMap(response.data));
    } on DioException catch (e) {
      throw _extractProblemDetails(e);
    }
  }

  Map<String, dynamic> _requireMap(Object? data) {
    final map = _extractMap(data);
    if (map == null) {
      throw const ProblemDetails(
        title: 'Respuesta inesperada',
        status: 500,
        detail: 'No se pudo procesar la respuesta del servidor.',
      );
    }
    return map;
  }

  Map<String, dynamic>? _extractMap(Object? data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    return null;
  }

  ProblemDetails _extractProblemDetails(DioException exception) {
    final err = exception.error;
    if (err is ProblemDetails) {
      return err;
    }
    return ProblemDetails(
      title: 'Error de conexión',
      status: exception.response?.statusCode,
      detail:
          exception.message ??
          'No se pudo completar la solicitud con el servicio de autenticación.',
      instance: exception.requestOptions.uri.path,
    );
  }
}
