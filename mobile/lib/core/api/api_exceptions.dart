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
  const UnauthorizedException({String message = 'Session expired. Please login again.'})
      : super(message: message, statusCode: 401);
}

/// 422 — Laravel validation errors.
class ValidationException extends ApiException {
  const ValidationException({
    required Map<String, dynamic> errors,
    String message = 'Validation failed.',
  }) : super(message: message, statusCode: 422, errors: errors);

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
  const ForbiddenException({String message = 'You do not have permission to perform this action.'})
      : super(message: message, statusCode: 403);
}

/// 404 — Resource not found.
class NotFoundException extends ApiException {
  const NotFoundException({String message = 'Resource not found.'})
      : super(message: message, statusCode: 404);
}

/// 500 — Server error.
class ServerException extends ApiException {
  const ServerException({String message = 'An unexpected server error occurred.'})
      : super(message: message, statusCode: 500);
}

/// No internet connection or DNS failure.
class NetworkException extends ApiException {
  const NetworkException({String message = 'No internet connection. Please check your network.'})
      : super(message: message, statusCode: null);
}
