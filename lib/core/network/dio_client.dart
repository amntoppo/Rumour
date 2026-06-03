import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:rumour_app/core/exceptions/network_exceptions.dart';
import 'package:rumour_app/core/network/remote_client.dart';

/// Dio-based implementation of [RemoteClient].
///
/// Maps HTTP verbs to the [RemoteClient] contract:
/// - [fetchOne]  → GET   (returns null on 404)
/// - [save]      → PUT   (full replace)
/// - [create]    → POST  (expects `{"id": "..."}` in response)
/// - [patch]     → PATCH (partial update)
/// - [remove]    → DELETE
///
/// All [DioException]s are converted into typed [AppException] subtypes
/// via [_mapError] so callers never need to import Dio.
class DioClient implements RemoteClient {
  DioClient({Dio? dio, String baseUrl = ''})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
                responseType: ResponseType.json,
                headers: const {
                  'Accept': 'application/json',
                  'Content-Type': 'application/json',
                },
              ),
            ) {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: true,
          responseBody: true,
          error: true,
          logPrint: (obj) => debugPrint(obj.toString()),
        ),
      );
    }
  }

  final Dio _dio;

  // ── RemoteClient ──────────────────────────────────────────────────────────

  @override
  Future<T?> fetchOne<T>(String path, FromMap<T> fromMap) async {
    final data = await _request('GET', path);
    return data == null ? null : fromMap(data);
  }

  @override
  Future<void> save<T>(String path, T value, ToMap<T> toMap) async {
    await _request('PUT', path, body: toMap(value));
  }

  @override
  Future<String> create<T>(
    String collectionPath,
    T value,
    ToMap<T> toMap,
  ) async {
    final data = await _request('POST', collectionPath, body: toMap(value));
    final id = data?['id'];
    if (id is String) return id;
    throw ResponseParseException(
      'POST $collectionPath did not return a string `id` field.',
    );
  }

  @override
  Future<void> patch<T>(String path, T value, ToMap<T> toMap) async {
    await _request('PATCH', path, body: toMap(value));
  }

  @override
  Future<void> remove(String path) async {
    await _request('DELETE', path);
  }

  // ── Extended helpers (not on RemoteClient, call directly when needed) ─────

  /// GET with optional query parameters — useful for search/filter endpoints.
  Future<T?> fetchWithQuery<T>(
    String path,
    FromMap<T> fromMap, {
    DataMap? queryParams,
    Map<String, String>? headers,
  }) async {
    final data = await _request(
      'GET',
      path,
      queryParams: queryParams,
      headers: headers,
    );
    return data == null ? null : fromMap(data);
  }

  /// GET that expects a JSON array, with an optional [rootKey] to unwrap it.
  Future<List<T>> fetchList<T>(
    String path,
    FromMap<T> fromMap, {
    DataMap? queryParams,
    Map<String, String>? headers,
    String? rootKey,
  }) async {
    final response = await _rawRequest(
      'GET',
      path,
      queryParams: queryParams,
      headers: headers,
    );
    final raw = response.data;
    final list =
        rootKey != null && raw is Map<String, dynamic> ? raw[rootKey] : raw;
    if (list is! List) {
      throw ResponseParseException(
        'GET $path did not return a list'
        '${rootKey != null ? ' at key "$rootKey"' : ''}.',
      );
    }
    return list
        .whereType<Map<String, dynamic>>()
        .map(fromMap)
        .toList(growable: false);
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Executes [method] and asserts the response body is a JSON object.
  /// Returns `null` for empty / no-content responses.
  Future<DataMap?> _request(
    String method,
    String path, {
    Object? body,
    DataMap? queryParams,
    Map<String, String>? headers,
  }) async {
    final response = await _rawRequest(
      method,
      path,
      body: body,
      queryParams: queryParams,
      headers: headers,
    );
    final responseData = response.data;
    if (responseData == null) return null;
    if (responseData is Map<String, dynamic>) return responseData;
    throw ResponseParseException(
      '$method $path returned an unexpected body type '
      '(${responseData.runtimeType}).',
    );
  }

  /// Executes the raw Dio request and maps [DioException] → typed exception.
  Future<Response<dynamic>> _rawRequest(
    String method,
    String path, {
    Object? body,
    DataMap? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      return await _dio.request<dynamic>(
        path,
        data: body,
        queryParameters: queryParams,
        options: Options(method: method, headers: headers),
      );
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// Converts [DioException] to a typed [AppException] subtype.
  Exception _mapError(DioException e) {
    final msg = e.message ?? 'Request failed.';
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(msg);

      case DioExceptionType.badResponse:
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          return UnauthorisedException(msg, statusCode: status);
        }
        if (status == 404) return ResourceNotFoundException(msg);
        return ServerException(msg, statusCode: status, body: e.response?.data);

      case DioExceptionType.cancel:
        return NetworkException('Request to $e was cancelled.');

      case DioExceptionType.badCertificate:
        return NetworkException('SSL certificate error: $msg');

      case DioExceptionType.unknown:
        return ServerException(msg);
    }
  }
}
