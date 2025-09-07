import 'package:dio/dio.dart';

class DioLoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    
    if (options.data != null) {
      print('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }


  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('--- DIO ERROR ---');
    print('<-- ${err.response?.statusCode} ${err.requestOptions.uri}');
    print('Error: ${err.error}');
    super.onError(err, handler);
  }
}