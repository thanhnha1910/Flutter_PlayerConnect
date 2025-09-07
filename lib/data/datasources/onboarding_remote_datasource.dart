import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/onboarding_request_model.dart';
import '../models/tag_model.dart';
import '../models/sport_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';

abstract class OnboardingRemoteDataSource {
  Future<List<SportModel>> getAllActiveSports();
  Future<List<TagModel>> getTagsBySport(int sportId);
  Future<void> submitOnboarding(OnboardingRequestModel request);
  Future<bool> checkOnboardingStatus();
}

@LazySingleton(as: OnboardingRemoteDataSource)
class OnboardingRemoteDataSourceImpl implements OnboardingRemoteDataSource {
  final ApiClient apiClient;

  OnboardingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<SportModel>> getAllActiveSports() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.activeSportsEndpoint,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        return data.map((json) => SportModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load sports',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}${ApiConstants.sportsEndpoint}'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<TagModel>> getTagsBySport(int sportId) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.sportTagsEndpoint.replaceAll('{sportId}', sportId.toString()),
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        return data.map((json) => TagModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load tags',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/sports/tags/$sportId'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> submitOnboarding(OnboardingRequestModel request) async {
    try {
      final response = await apiClient.dio.put(
        ApiConstants.onboardingEndpoint,
        data: request.toJson(),
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to submit onboarding',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/onboarding'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<bool> checkOnboardingStatus() async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.onboardingStatusEndpoint,
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('completed')) {
          return data['completed'] as bool;
        } else if (data is Map && data.containsKey('data')) {
          final innerData = data['data'] as Map;
          return innerData['completed'] as bool;
        } else {
          return false;
        }
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to check onboarding status',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/user/onboarding-status'),
        message: e.toString(),
      );
    }
  }
}