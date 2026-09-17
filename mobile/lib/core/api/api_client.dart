import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';
import 'api_exceptions.dart';

/// Central Dio HTTP client for communicating with the Laravel Sanctum backend.
///
/// Features:
/// - Auto-attaches Bearer token from SecureStorage
/// - Maps HTTP errors to typed [ApiException] subclasses
/// - Configurable base URL
class ApiClient {
  late final Dio _dio;
  final SecureStorage _storage;

  final VoidCallback? onUnauthorized;

  /// Production server URL (cPanel).
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://presensi.lemdiklattarunanusantaraindonesia.id/api',
  );
  ApiClient({
    SecureStorage? storage,
    String? baseUrl,
    this.onUnauthorized,
  }) : _storage = storage ?? SecureStorage() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _AuthInterceptor(_storage),
      // Logging is opt-in and deliberately excludes credentials, request
      // payloads, and biometric/API response data.
      if (const bool.fromEnvironment('API_LOGGING'))
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: true,
        ),
      _ErrorInterceptor(onUnauthorized: onUnauthorized),
    ]);
  }

  // ── HTTP Methods ───────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _execute(() => _dio.get(path, queryParameters: queryParameters));
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) {
    return _execute(() => _dio.post(path, data: data));
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) {
    return _execute(() => _dio.put(path, data: data));
  }

  Future<Response> delete(String path) {
    return _execute(() => _dio.delete(path));
  }

  /// For multipart file uploads (e.g. claim receipts).
  Future<Response> upload(
    String path, {
    required FormData formData,
  }) {
    return _execute(() => _dio.post(
          path,
          data: formData,
        ));
  }

  /// For downloading files (e.g. payslip PDFs).
  Future<Response> download(
    String path,
    String savePath,
  ) {
    return _execute(() => _dio.download(path, savePath));
  }

  Future<Response> _execute(Future<Response> Function() request) async {
    try {
      return await request();
    } on DioException catch (error) {
      if (error.error is ApiException) throw error.error as ApiException;
      throw ApiException(
        message: error.message ?? 'Permintaan API gagal diproses.',
        statusCode: error.response?.statusCode,
      );
    }
  }
}

// ── Auth Interceptor ───────────────────────────────────────────────────────

class _AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  _AuthInterceptor(this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Don't attach token to the login endpoint
    if (options.path.contains('/login')) {
      return handler.next(options);
    }

    final token = await _storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }
}

// ── Error Interceptor ──────────────────────────────────────────────────────

class _ErrorInterceptor extends Interceptor {
  final VoidCallback? onUnauthorized;

  _ErrorInterceptor({this.onUnauthorized});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    // Network error (no response received)
    if (response == null &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.sendTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.unknown)) {
      return handler.reject(err.copyWith(error: const NetworkException()));
    }

    if (err.type == DioExceptionType.cancel) {
      return handler.reject(err.copyWith(
        error: const ApiException(message: 'Permintaan dibatalkan.'),
      ));
    }

    final statusCode = response?.statusCode;
    final data = response?.data;
    final rawErrors = data is Map ? data['errors'] : null;
    final firstValidationMessage = rawErrors is Map
        ? rawErrors.values
            .whereType<List>()
            .expand((messages) => messages)
            .map((message) => message.toString())
            .firstOrNull
        : null;
        
    final message = (statusCode == 422 && firstValidationMessage != null)
        ? firstValidationMessage
        : (data is Map && data['message'] != null
            ? data['message'].toString()
            : firstValidationMessage ??
                (data is String && data.trim().isNotEmpty
                    ? 'Server mengembalikan respons yang tidak valid.'
                    : 'Server tidak dapat memproses permintaan.'));

    final ApiException exception;
    switch (statusCode) {
      case 401:
        exception = const UnauthorizedException();
        // Login/logout are authentication lifecycle requests. Triggering the
        // global unauthorized callback for either endpoint can create an
        // endless logout -> 401 -> logout loop on Android.
        final path = err.requestOptions.path;
        final isAuthLifecycleRequest =
            path.endsWith('/login') || path.endsWith('/logout');
        if (!isAuthLifecycleRequest) {
          onUnauthorized?.call();
        }
        break;
      case 403:
        exception = ForbiddenException(message: message);
        break;
      case 404:
        exception = NotFoundException(message: message);
        break;
      case 422:
        final errors = rawErrors is Map
            ? Map<String, dynamic>.from(rawErrors)
            : <String, dynamic>{};
        exception = ValidationException(errors: errors, message: message);
        break;
      case 409:
        exception = ApiException(message: message, statusCode: 409);
        break;
      case 429:
        exception = ApiException(message: message, statusCode: 429);
        break;
      default:
        exception = ServerException(message: message);
    }
    handler.reject(err.copyWith(error: exception));
  }
}
