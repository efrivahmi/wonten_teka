/// Typed API exceptions that map to HTTP error responses from the Laravel backend.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// 401 — Sanctum token expired or invalid.
class UnauthorizedException extends ApiException {
  const UnauthorizedException(
      {super.message = 'Session expired. Please login again.'})
      : super(statusCode: 401);
}

/// 422 — Laravel validation errors.
class ValidationException extends ApiException {
  const ValidationException({
    required Map<String, dynamic> super.errors,
    super.message = 'Validation failed.',
  }) : super(statusCode: 422);

  /// Get the first error message for a specific field.
  String? fieldError(String field) {
    final fieldErrors = errors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }

  /// Get all error messages as a flat list.
  List<String> get allErrors {
    if (errors == null) return [message];
    return errors!.values
        .whereType<List>()
        .expand((list) => list)
        .map((e) => e.toString())
        .toList();
  }
}

/// 403 — Forbidden (e.g. employee profile not found).
class ForbiddenException extends ApiException {
  const ForbiddenException(
      {super.message = 'You do not have permission to perform this action.'})
      : super(statusCode: 403);
}

/// 404 — Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Resource not found.'})
      : super(statusCode: 404);
}

/// 500 — Server error.
class ServerException extends ApiException {
  const ServerException(
      {super.message = 'An unexpected server error occurred.'})
      : super(statusCode: 500);
}

/// No internet connection or DNS failure.
class NetworkException extends ApiException {
  const NetworkException(
      {super.message = 'No internet connection. Please check your network.'})
      : super(statusCode: null);
}
