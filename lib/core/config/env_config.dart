/// Compile-time environment configuration injected via `--dart-define`.
///
/// Example usage:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.example.com/api/v1
/// ```
final class EnvConfig {
  const EnvConfig._();

  /// Base URL for the backend API injected at compile time.
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Validates that all required compile-time environment variables are present.
  ///
  /// Throws a [StateError] at startup if [apiBaseUrl] was not provided or is empty.
  static void validate([String? overrideBaseUrl]) {
    final resolvedUrl = (overrideBaseUrl ?? apiBaseUrl).trim();
    if (resolvedUrl.isEmpty) {
      throw StateError(
        'Missing required environment variable: API_BASE_URL. '
        'Provide it at build/run time using --dart-define=API_BASE_URL=<url>.',
      );
    }

    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      throw StateError(
        'Invalid API_BASE_URL "$resolvedUrl". A valid absolute HTTP/HTTPS URL is required.',
      );
    }
  }
}
