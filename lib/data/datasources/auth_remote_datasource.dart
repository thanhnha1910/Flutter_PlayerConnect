import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/jwt_response_model.dart';
import '../models/auth_request_models.dart';

import 'package:injectable/injectable.dart';

abstract class AuthRemoteDataSource {
  Future<JwtResponseModel> login(String email, String password);
  Future<JwtResponseModel> register(RegisterRequest request);
  Future<JwtResponseModel> loginWithGoogle();
  Future<void> forgotPassword(String email);
  Future<JwtResponseModel> refreshToken(String refreshToken);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final GoogleSignIn googleSignIn;
  
  AuthRemoteDataSourceImpl(this.apiClient, this.googleSignIn);

  @override
  Future<JwtResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );
      
      return JwtResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  @override
  Future<JwtResponseModel> login(String email, String password) async {
    final loginRequest = LoginRequest(email: email, password: password);
    final requestData = loginRequest.toJson();

    try {
      final response = await apiClient.dio.post(
        ApiConstants.loginEndpoint,
        data: requestData,
      );
      
      final jwtResponse = JwtResponseModel.fromJson(response.data);
      return jwtResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      rethrow;
    }
  }
  
  @override
  Future<JwtResponseModel> register(RegisterRequest request) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.registerEndpoint,
        data: request.toJson(),
      );
      
      return JwtResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  @override
  Future<JwtResponseModel> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in was cancelled');
      }
      
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;
      
      final response = await apiClient.dio.post(
        ApiConstants.googleAuthEndpoint,
        data: {
          'code': googleAuth.accessToken,
        },
      );
      
      return JwtResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  @override
  Future<void> forgotPassword(String email) async {
    try {
      await apiClient.dio.post(
        ApiConstants.forgotPasswordEndpoint,
        data: ForgotPasswordRequest(email: email).toJson(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
  
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      
      switch (statusCode) {
        case 400:
          // Bad request - thường là validation errors
          final message = responseData?['message'] ?? 'Yêu cầu không hợp lệ';
          return Exception(message);
        case 401:
          // Unauthorized - sai thông tin đăng nhập
          final message = responseData?['message'] ?? 'Email hoặc mật khẩu không đúng';
          return Exception(message);
        case 403:
          // Forbidden - tài khoản bị khóa hoặc chưa xác thực
          final message = responseData?['message'] ?? 'Tài khoản của bạn đã bị khóa hoặc chưa được xác thực';
          return Exception(message);
        case 404:
          // Not found - email không tồn tại
          final message = responseData?['message'] ?? 'Email không tồn tại trong hệ thống';
          return Exception(message);
        case 500:
          // Server error
          return Exception('Lỗi máy chủ. Vui lòng thử lại sau');
        default:
          final message = responseData?['message'] ?? 'Đã xảy ra lỗi không xác định';
          return Exception(message);
      }
    } else {
      // Network errors
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Kết nối bị timeout. Vui lòng kiểm tra mạng và thử lại');
        case DioExceptionType.connectionError:
          return Exception('Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng');
        case DioExceptionType.cancel:
          return Exception('Yêu cầu đã bị hủy');
        default:
          return Exception('Lỗi mạng: ${e.message}');
      }
    }
  }
}