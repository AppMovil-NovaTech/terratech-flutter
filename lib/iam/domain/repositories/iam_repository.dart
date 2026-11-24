import '../entities/auth_session.dart';
import '../entities/user_profile.dart';

/// Result returned when registering a new TerraTech account (US06).
class SignUpResult {
  const SignUpResult({
    required this.userId,
    required this.emailAddress,
    required this.fullName,
    required this.emailVerificationRequired,
  });

  final int userId;
  final String emailAddress;
  final String fullName;
  final bool emailVerificationRequired;
}

/// Contract for the IAM and Self-Profile bounded context.
abstract interface class IamRepository {
  /// Restores a previously persisted session if a valid, non-expired token exists.
  Future<AuthSession?> restoreSession();

  /// Authenticates a user via `/api/v1/authentication/sign-in` (US07).
  Future<AuthSession> signIn({
    required String emailAddress,
    required String password,
  });

  /// Registers a new farmer/customer account via `/api/v1/authentication/sign-up` (US06).
  Future<SignUpResult> signUp({
    required String fullName,
    required String emailAddress,
    required String password,
    required String confirmPassword,
  });

  /// Requests a password reset token email via `/api/v1/authentication/password-reset-requests` (US08).
  Future<String> requestPasswordReset({required String emailAddress});

  /// Completes password recovery via `/api/v1/authentication/password-resets` (US08).
  Future<void> resetPassword({
    required String token,
    required String password,
    required String confirmPassword,
  });

  /// Fetches the authenticated user's basic identity from `/api/v1/users/me`.
  Future<AuthSession> refreshCurrentUser();

  /// Clears all locally persisted session credentials.
  Future<void> signOut();

  /// Returns the current user's profile from `/api/v1/profiles/me`, or `null` if
  /// the user has not created one yet (US09).
  Future<UserProfile?> getMyProfile();

  /// Creates or updates the authenticated user's profile at `/api/v1/profiles/me` (US09).
  Future<UserProfile> upsertMyProfile(UpsertUserProfileInput input);
}
