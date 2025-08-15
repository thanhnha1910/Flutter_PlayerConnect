import 'package:dio/dio.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('--- DIO REQUEST ---');
    print('--> ${options.method.toUpperCase()} ${options.uri}');
    print('Headers: ${options.headers}');
    print('Query Parameters: ${options.queryParameters}');
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    print('--> END ${options.method.toUpperCase()}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('--- DIO RESPONSE ---');
    print('<-- ${response.statusCode} ${response.requestOptions.uri}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('--- DIO ERROR ---');
    print('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Error: ${err.error}');
    super.onError(err, handler);
  }
}