import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../data/models/ai_recommendation_model.dart' hide OpenMatchModel;
import '../../data/models/open_match_model.dart';
import '../network/api_client.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

@lazySingleton
class AIRecommendationService {
  final ApiClient _apiClient;
  final SecureStorage _secureStorage;

  AIRecommendationService(this._apiClient, this._secureStorage);

  // Get AI recommendations for teammates based on booking ID
  Future<AIRecommendationResponse> getTeammateRecommendations(
    String bookingId,
  ) async {
    try {
      final endpoint = ApiConstants.aiRecommendTeammatesEndpoint.replaceAll('{bookingId}', bookingId);
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

  // Get recommended count for teammates based on booking
  Future<int> getRecommendedCount(String bookingId) async {
    try {
      final endpoint = ApiConstants.aiRecommendTeammatesEndpoint.replaceAll('{bookingId}', bookingId);
      final response = await _apiClient.dio.get(endpoint);
      
      // Parse response to get count from totalRecommendations field
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('totalRecommendations')) {
        return data['totalRecommendations'] as int? ?? 0;
      } else if (data.containsKey('data') && data['data'] is Map) {
        final dataMap = data['data'] as Map<String, dynamic>;
        if (dataMap.containsKey('totalRecommendations')) {
          return dataMap['totalRecommendations'] as int? ?? 0;
        }
        // Fallback: count recommendedPlayers array length
        if (dataMap.containsKey('recommendedPlayers') && dataMap['recommendedPlayers'] is List) {
          return (dataMap['recommendedPlayers'] as List).length;
        }
      }
      // Fallback: count recommendedPlayers array length from root
      if (data.containsKey('recommendedPlayers') && data['recommendedPlayers'] is List) {
        return (data['recommendedPlayers'] as List).length;
      }
      return 0;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return 0; // No recommendations found
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else {
        throw Exception('Failed to get recommended count: ${e.message}');
      }
    } catch (e) {
      // Return 0 instead of throwing error for better UX
      return 0;
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
      // Get current user ID first
      final userData = await _secureStorage.getUserData();
      final currentUserId = userData['userId'];
      
      final queryParams = <String, dynamic>{
        'page': page.toString(),
        'size': size.toString(),
      };

      // Add userId to query params so backend can calculate currentUserJoinStatus
      if (currentUserId != null) {
        queryParams['userId'] = currentUserId.toString();
      }

      if (location != null) queryParams['location'] = location;
      if (fieldType != null) queryParams['fieldType'] = fieldType;
      if (date != null)
        queryParams['date'] = date.toIso8601String().split('T')[0];

      final response = await _apiClient.dio.get(
        ApiConstants.openMatchesWithUserInfoEndpoint,
        queryParameters: queryParams,
      );
      
      // API returns data wrapped in 'data' field
      final responseData = response.data as Map<String, dynamic>;
      final matchesData = responseData['data'] as List<dynamic>? ?? [];
      return matchesData
          .map(
            (match) => OpenMatchModel.fromJson(
              match as Map<String, dynamic>,
              currentUserId: currentUserId,
            ),
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
    required int slotsNeeded,
    List<String>? requiredTags,
    String? sportType,
  }) async {
    try {
      final requestBody = {
        'bookingId': int.parse(bookingId),
        'sportType': sportType ?? 'BONG_DA',
        'slotsNeeded': slotsNeeded,
        'requiredTags': requiredTags ?? [],
      };

      final response = await _apiClient.dio.post(
        ApiConstants.openMatchesEndpoint,
        data: requestBody,
      );

      // Get current user ID for isCreator calculation
      final userData = await _secureStorage.getUserData();
      final currentUserId = userData['userId'];

      // Backend returns ApiResponse wrapper with data field
      final responseData = response.data as Map<String, dynamic>;
      final openMatchData = responseData['data'] as Map<String, dynamic>;
      
      return OpenMatchModel.fromJson(openMatchData, currentUserId: currentUserId);
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

  // Send invitation to a recommended player using unified invitation API
  Future<void> sendInvitation({
    required String inviteeId,
    required String openMatchId,
  }) async {
    try {
      final requestBody = {
        'inviteeId': int.parse(inviteeId),
        'openMatchId': int.parse(openMatchId),
      };

      final response = await _apiClient.dio.post(
        ApiConstants.invitationsEndpoint,
        data: requestBody,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send invitation');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid invitation data');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Unauthorized access');
      } else if (e.response?.statusCode == 404) {
        throw Exception('Player or open match not found');
      } else {
        throw Exception('Failed to send invitation: ${e.message}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Legacy method - kept for backward compatibility
  @deprecated
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
