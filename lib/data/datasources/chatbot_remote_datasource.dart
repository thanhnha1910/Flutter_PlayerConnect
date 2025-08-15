import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../models/chatbot_models.dart';

abstract class ChatbotRemoteDataSource {
  Future<ChatbotResponseDTO> sendMessage(ChatbotRequestDTO request);
  Future<bool> checkHealth();
}

@LazySingleton(as: ChatbotRemoteDataSource)
class ChatbotRemoteDataSourceImpl implements ChatbotRemoteDataSource {
  final ApiClient _apiClient;

  ChatbotRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<ChatbotResponseDTO> sendMessage(ChatbotRequestDTO request) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.chatbotQueryEndpoint}',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return ChatbotResponseDTO.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<bool> checkHealth() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.chatbotHealthEndpoint}',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      return false;
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet.');
      case DioExceptionType.badResponse:
        return Exception('Server error: ${e.response?.statusCode}');
      default:
        return Exception('Network error occurred');
    }
  }
}