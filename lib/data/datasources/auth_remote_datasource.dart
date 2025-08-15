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
      final message = e.response?.data['message'] ?? 'Đã xảy ra lỗi';
      return Exception(message);
    } else {
      return Exception('Không thể kết nối đến máy chủ');
    }
  }
}