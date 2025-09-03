import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/ai_recommendation_model.dart' hide OpenMatchModel;
import '../../data/models/open_match_model.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';

@lazySingleton
class AIRecommendationService {
  final ApiClient _apiClient;

  AIRecommendationService(this._apiClient);

  // Get AI recommendations for teammates based on booking
  Future<AIRecommendationResponse> getTeammateRecommendations(
    String bookingId,
  ) async {
    try {
      final endpoint = ApiConstants.aiRecommendTeammatesEndpoint.replaceAll(
        '{id}',
        bookingId,
      );
      final response = await _apiClient.dio.get(endpoint);
      return AIRecommendationResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Booking not found');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get recommendations: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get open matches for Find Match feature
  Future<List<OpenMatchModel>> getOpenMatches({
    String? location,
    String? fieldType,
    DateTime? date,
    int page = 0,
    int size = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'size': size.toString(),
      };

      if (location != null) queryParams['location'] = location;
      if (fieldType != null) queryParams['fieldType'] = fieldType;
      if (date != null)
        queryParams['date'] = date.toIso8601String().split('T')[0];

      final response = await _apiClient.dio.get(
        ApiConstants.openMatchesEndpoint,
        queryParameters: queryParams,
      );

      // API returns data wrapped in 'data' field
      final responseData = response.data as Map<String, dynamic>;
      final matchesData = responseData['data'] as List<dynamic>? ?? [];
      return matchesData
          .map(
            (match) => OpenMatchModel.fromJson(match as Map<String, dynamic>),
          )
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get open matches: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Send join request to an open match (creates invitation)
  Future<void> sendJoinRequest(String matchId) async {
    try {
      final endpoint = ApiConstants.joinOpenMatchEndpoint.replaceAll(
        '{id}',
        matchId,
      );
      await _apiClient.dio.post(endpoint);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Cannot send join request');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Match not found');
      } else {
        throw Exception('Failed to send join request: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Join an open match (deprecated - use sendJoinRequest instead)
  @deprecated
  Future<void> joinOpenMatch(String matchId) async {
    try {
      await _apiClient.dio.post(
        '${ApiConstants.openMatchesEndpoint}/$matchId/join',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Cannot join this match');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Match not found');
      } else {
        throw Exception('Failed to join match: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Leave an open match
  Future<void> leaveOpenMatch(String matchId) async {
    try {
      final endpoint = ApiConstants.leaveOpenMatchEndpoint.replaceAll(
        '{id}',
        matchId,
      );
      await _apiClient.dio.delete(endpoint);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Cannot leave this match');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Match not found');
      } else {
        throw Exception('Failed to leave match: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Create an open match from booking
  Future<OpenMatchModel> createOpenMatchFromBooking({
    required String bookingId,
    required String title,
    required String description,
    required int maxPlayers,
    required double pricePerPlayer,
    List<String>? tags,
    String? skillLevelRequired,
  }) async {
    try {
      final requestBody = {
        'bookingId': bookingId,
        'title': title,
        'description': description,
        'maxPlayers': maxPlayers,
        'pricePerPlayer': pricePerPlayer,
        'tags': tags ?? [],
        'skillLevelRequired': skillLevelRequired,
      };

      final response = await _apiClient.dio.post(
        ApiConstants.openMatchesEndpoint,
        data: requestBody,
      );

      return OpenMatchModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorData = e.response?.data as Map<String, dynamic>?;
        throw Exception(errorData?['message'] ?? 'Invalid match data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Booking not found');
      } else {
        throw Exception('Failed to create open match: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Send invitation to a recommended player
  Future<PlayerInvitationModel> sendPlayerInvitation({
    required String bookingId,
    required String inviteeId,
    required String message,
  }) async {
    try {
      final requestBody = {
        'bookingId': bookingId,
        'inviteeId': inviteeId,
        'message': message,
      };

      final response = await _apiClient.dio.post(
        ApiConstants.playerInvitationEndpoint,
        data: requestBody,
      );

      return PlayerInvitationModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid invitation data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Player or booking not found');
      } else {
        throw Exception('Failed to send invitation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
