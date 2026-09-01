import 'package:dio/dio.dart';
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

  /// Production server URL (cPanel).
  static const String _productionBaseUrl =
      'https://presensi.lemdiklattarunanusantaraindonesia.id/api';

  /// Local development URL (via USB `adb reverse tcp:8000 tcp:8000`).
  static const String _localBaseUrl = 'http://127.0.0.1:8000/api';

  /// Set to `true` to use the production AWS server,
  /// or `false` to use local `php artisan serve`.
  static const bool _useProduction = true;

  static String get _defaultBaseUrl =>
      _useProduction ? _productionBaseUrl : _localBaseUrl;
  ApiClient({
    required SecureStorage storage,
    String? baseUrl,
  }) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? _defaultBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      LogInterceptor(request: true, requestHeader: true, requestBody: true, responseHeader: true, responseBody: true, error: true),
      _AuthInterceptor(_storage),
      _ErrorInterceptor(),
    ]);
  }

  // ── HTTP Methods ───────────────────────────────────────────────────────

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(
    String path, {
    dynamic data,
  }) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(
    String path, {
    dynamic data,
  }) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }

  /// For multipart file uploads (e.g. claim receipts).
  Future<Response> upload(
    String path, {
    required FormData formData,
  }) {
    return _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }

  /// For downloading files (e.g. payslip PDFs).
  Future<Response> download(
    String path,
    String savePath,
  ) {
    return _dio.download(path, savePath);
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
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final response = err.response;

    // Network error (no response received)
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.unknown) {
      throw const NetworkException();
    }

    final statusCode = response?.statusCode;
    final data = response?.data;
    final message = data is Map
        ? (data['message'] as String? ?? 'An error occurred')
        : 'An error occurred';

    switch (statusCode) {
      case 401:
        throw const UnauthorizedException();
      case 403:
        throw ForbiddenException(message: message);
      case 404:
        throw NotFoundException(message: message);
      case 422:
        final errors =
            data is Map ? (data['errors'] as Map<String, dynamic>?) : null;
        throw ValidationException(errors: errors ?? {}, message: message);
      default:
        throw ServerException(message: message);
    }
  }
}
