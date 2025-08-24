import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

@lazySingleton
class ApiClient {
  final Dio _dio;
  final SecureStorage _secureStorage;

  ApiClient(this._dio, this._secureStorage, {required Dio dio}) {
    _dio.options.baseUrl = ApiConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    // Add enhanced interceptor for authentication and error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final token = await _secureStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers[ApiConstants.authorization] =
                  '${ApiConstants.bearer} $token';
              if (kDebugMode) {
                print('[API] Request to ${options.path} with token: ${token.substring(0, 20)}...');
              }
            } else {
              if (kDebugMode) {
                print('[API] Request to ${options.path} without token');
              }
            }

            // Add common headers
            options.headers['Content-Type'] = ApiConstants.contentType;
            options.headers['Accept'] = ApiConstants.contentType;

          } catch (e) {
            if (kDebugMode) {
              print('[API] Error adding auth header: $e');
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('[API] Response ${response.statusCode} from ${response.requestOptions.path}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final newAccessToken = await _refreshToken();

              // Clone the original request and update the token
              final options = error.requestOptions;
              options.headers[ApiConstants.authorization] =
                  '${ApiConstants.bearer} $newAccessToken';

              // Retry the request
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              if (kDebugMode) {
                print('[API] Refresh token failed: $e');
              }
              await _secureStorage.clearAll();
              // You might want to navigate to the login screen here
              return handler.next(error);
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debugging
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
          logPrint: (obj) => debugPrint('[DIO] $obj'),
        ),
      );
    }
  }

  Future<String> _refreshToken() async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await _dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['token'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _secureStorage.saveToken(newAccessToken);
      await _secureStorage.saveRefreshToken(newRefreshToken);

      return newAccessToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.clearAll();
      }
      throw Exception('Failed to refresh token');
    }
  }

  Dio get dio => _dio;
}