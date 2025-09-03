import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/invitation_model.dart';
import '../models/open_match_join_request_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';

abstract class InvitationRemoteDataSource {
  Future<InvitationListResponse> getReceivedInvitations({
    int page = 0,
    int size = 10,
  });

  Future<InvitationListResponse> getSentInvitations({
    int page = 0,
    int size = 10,
  });

  Future<DraftMatchRequestListResponse> getReceivedDraftMatchRequests({
    int page = 0,
    int size = 10,
  });

  Future<DraftMatchRequestListResponse> getSentDraftMatchRequests({
    int page = 0,
    int size = 10,
  });

  Future<void> respondToInvitation(
    int invitationId,
    InvitationActionRequest request,
  );

  Future<void> acceptDraftMatchRequest(int draftMatchId, int userId);
  Future<void> rejectDraftMatchRequest(int draftMatchId, int userId);

  // Open Match Join Request methods
  Future<void> sendOpenMatchJoinRequest(
    int openMatchId,
    SendOpenMatchJoinRequestModel request,
  );

  Future<OpenMatchJoinRequestListResponse> getReceivedOpenMatchJoinRequests({
    int page = 0,
    int size = 10,
  });

  Future<OpenMatchJoinRequestListResponse> getSentOpenMatchJoinRequests({
    int page = 0,
    int size = 10,
  });

  Future<void> approveOpenMatchJoinRequest(int requestId);
  Future<void> rejectOpenMatchJoinRequest(int requestId);
}

@LazySingleton(as: InvitationRemoteDataSource)
class InvitationRemoteDataSourceImpl implements InvitationRemoteDataSource {
  final Dio dio;

  InvitationRemoteDataSourceImpl(this.dio);

  @override
  Future<InvitationListResponse> getReceivedInvitations({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.receivedInvitationsEndpoint}',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        // Handle both array and object response formats
        Map<String, dynamic> responseMap;
        if (response.data is List) {
          // Backend returns array directly
          final List<dynamic> invitationsList = response.data;
          responseMap = {
            'invitations': invitationsList,
            'totalElements': invitationsList.length,
            'totalPages': 1,
            'currentPage': 0,
          };
        } else {
          // Backend returns object wrapper
          responseMap = response.data;
        }
        return InvitationListResponse.fromJson(responseMap);
      } else {
        throw ServerException('Failed to fetch received invitations');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<InvitationListResponse> getSentInvitations({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.sentInvitationsEndpoint}',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        // Handle both array and object response formats
        Map<String, dynamic> responseMap;
        if (response.data is List) {
          // Backend returns array directly
          final List<dynamic> invitationsList = response.data;
          responseMap = {
            'invitations': invitationsList,
            'totalElements': invitationsList.length,
            'totalPages': 1,
            'currentPage': 0,
          };
        } else {
          // Backend returns object wrapper
          responseMap = response.data;
        }
        return InvitationListResponse.fromJson(responseMap);
      } else {
        throw ServerException('Failed to fetch sent invitations');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<DraftMatchRequestListResponse> getReceivedDraftMatchRequests({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.receivedDraftMatchRequestsEndpoint}',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        // Handle both ApiResponse wrapper and direct array response
        dynamic responseData = response.data;

        // Check if response is wrapped in ApiResponse format
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          // Extract the data from ApiResponse wrapper
          List<dynamic> requests = responseData['data'] ?? [];

          // Create a map with expected structure for DraftMatchRequestListResponse
          Map<String, dynamic> formattedData = {
            'requests': requests,
            'totalElements': requests.length,
            'totalPages': 1,
            'currentPage': page,
          };

          return DraftMatchRequestListResponse.fromJson(formattedData);
        } else if (responseData is List) {
          // Handle direct array response (fallback)
          Map<String, dynamic> formattedData = {
            'requests': responseData,
            'totalElements': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };

          return DraftMatchRequestListResponse.fromJson(formattedData);
        } else {
          // Assume it's already in the expected format
          return DraftMatchRequestListResponse.fromJson(responseData);
        }
      } else {
        throw ServerException('Failed to fetch received draft match requests');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<DraftMatchRequestListResponse> getSentDraftMatchRequests({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.sentDraftMatchRequestsEndpoint}',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        // Handle both ApiResponse wrapper and direct array response
        dynamic responseData = response.data;

        // Check if response is wrapped in ApiResponse format
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          // Extract the data from ApiResponse wrapper
          List<dynamic> requests = responseData['data'] ?? [];

          // Create a map with expected structure for DraftMatchRequestListResponse
          Map<String, dynamic> formattedData = {
            'requests': requests,
            'totalElements': requests.length,
            'totalPages': 1,
            'currentPage': page,
          };

          return DraftMatchRequestListResponse.fromJson(formattedData);
        } else if (responseData is List) {
          // Handle direct array response (fallback)
          Map<String, dynamic> formattedData = {
            'requests': responseData,
            'totalElements': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };

          return DraftMatchRequestListResponse.fromJson(formattedData);
        } else {
          // Assume it's already in the expected format
          return DraftMatchRequestListResponse.fromJson(responseData);
        }
      } else {
        throw ServerException('Failed to fetch sent draft match requests');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> respondToInvitation(
    int invitationId,
    InvitationActionRequest request,
  ) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.respondToInvitationEndpoint}'
            .replaceAll('{id}', invitationId.toString()),
        data: request.toJson(),
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to respond to invitation');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> acceptDraftMatchRequest(int draftMatchId, int userId) async {
    try {
      final endpoint = ApiConstants.acceptUserEndpoint
          .replaceAll('{id}', draftMatchId.toString())
          .replaceAll('{userId}', userId.toString());
      final response = await dio.post('${ApiConstants.baseUrl}$endpoint');

      if (response.statusCode != 200) {
        throw ServerException('Failed to accept draft match request');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> rejectDraftMatchRequest(int draftMatchId, int userId) async {
    try {
      final endpoint = ApiConstants.rejectUserEndpoint
          .replaceAll('{id}', draftMatchId.toString())
          .replaceAll('{userId}', userId.toString());
      final response = await dio.post('${ApiConstants.baseUrl}$endpoint');

      if (response.statusCode != 200) {
        throw ServerException('Failed to reject draft match request');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> sendOpenMatchJoinRequest(
    int openMatchId,
    SendOpenMatchJoinRequestModel request,
  ) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.joinOpenMatchEndpoint}'
            .replaceAll('{id}', openMatchId.toString()),
        data: request.toJson(),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to send open match join request');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<OpenMatchJoinRequestListResponse> getReceivedOpenMatchJoinRequests({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/invitations/received',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          List<dynamic> requests = responseData['data'] ?? [];
          Map<String, dynamic> formattedData = {
            'requests': requests,
            'totalElements': requests.length,
            'totalPages': 1,
            'currentPage': page,
          };
          return OpenMatchJoinRequestListResponse.fromJson(formattedData);
        } else if (responseData is List) {
          Map<String, dynamic> formattedData = {
            'requests': responseData,
            'totalElements': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };
          return OpenMatchJoinRequestListResponse.fromJson(formattedData);
        } else {
          return OpenMatchJoinRequestListResponse.fromJson(responseData);
        }
      } else {
        throw ServerException(
          'Failed to fetch received open match join requests',
        );
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<OpenMatchJoinRequestListResponse> getSentOpenMatchJoinRequests({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.baseUrl}/invitations/sent',
        queryParameters: {'page': page, 'size': size},
      );

      if (response.statusCode == 200) {
        dynamic responseData = response.data;

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('data')) {
          List<dynamic> requests = responseData['data'] ?? [];
          Map<String, dynamic> formattedData = {
            'requests': requests,
            'totalElements': requests.length,
            'totalPages': 1,
            'currentPage': page,
          };
          return OpenMatchJoinRequestListResponse.fromJson(formattedData);
        } else if (responseData is List) {
          Map<String, dynamic> formattedData = {
            'requests': responseData,
            'totalElements': responseData.length,
            'totalPages': 1,
            'currentPage': page,
          };
          return OpenMatchJoinRequestListResponse.fromJson(formattedData);
        } else {
          return OpenMatchJoinRequestListResponse.fromJson(responseData);
        }
      } else {
        throw ServerException('Failed to fetch sent open match join requests');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> approveOpenMatchJoinRequest(int requestId) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/invitations/join-requests/$requestId/accept',
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to approve open match join request');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> rejectOpenMatchJoinRequest(int requestId) async {
    try {
      final response = await dio.post(
        '${ApiConstants.baseUrl}/invitations/join-requests/$requestId/reject',
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to reject open match join request');
      }
    } on DioException catch (e) {
      throw ServerException('Network error: ${e.message}');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
