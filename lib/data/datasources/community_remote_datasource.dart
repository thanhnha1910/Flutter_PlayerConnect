import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/constants/api_constants.dart';
import 'package:player_connect/core/network/api_client.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/post_models.dart';
import 'package:player_connect/data/models/draft_match_model.dart';
import 'package:player_connect/data/models/user_model.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostResponse>> getPosts(int userId);
  Future<PostResponse> createPost(PostRequest request);
  Future<void> likePost(int postId, int userId);
  Future<List<CommentResponse>> getCommentsForPost(int postId, int userId);
  Future<CommentResponse> createComment(
    int postId,
    int userId,
    CommentRequest request,
  );
  Future<void> likeComment(int commentId, int userId);
  Future<CommentResponse> replyToComment(
    int parentCommentId,
    ReplyCommentRequest request,
  );
  Future<Map<String, String>> generateAiContent(Uint8List imageBytes);

  // Draft Match methods
  Future<DraftMatchResponse> createDraftMatch(CreateDraftMatchRequest request);
  Future<DraftMatchListResponse> getActiveDraftMatches({
    String? sportType,
    bool? aiRanked,
  });
  Future<DraftMatchListResponse> getMyDraftMatches();
  Future<DraftMatchListResponse> getPublicDraftMatches({
    String? sportType,
    bool? aiRanked,
  });
  Future<DraftMatchListResponse> getRankedDraftMatches({String? sportType});
  Future<DraftMatchListResponse> getDraftMatchesWithUserInfo({
    String? sportType,
    bool? aiRanked,
  });
  Future<DraftMatchResponse> expressInterest(int draftMatchId);
  Future<DraftMatchResponse> withdrawInterest(int draftMatchId);
  Future<DraftMatchResponse> acceptUser(int draftMatchId, int userId);
  Future<DraftMatchResponse> rejectUser(int draftMatchId, int userId);
  Future<DraftMatchResponse> convertToMatch(int draftMatchId);
  Future<DraftMatchResponse> updateDraftMatch(
    int draftMatchId,
    CreateDraftMatchRequest request,
  );
  Future<List<UserModel>> getInterestedUsers(int draftMatchId);
  Future<DraftMatchResponse> initiateDraftMatchBooking(
    int draftMatchId,
    Map<String, dynamic> bookingData,
  );
  Future<DraftMatchResponse> completeDraftMatchBooking(
    int draftMatchId,
    int bookingId,
  );
}

@LazySingleton(as: CommunityRemoteDataSource)
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final ApiClient _apiClient;

  CommunityRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // Helper method to handle DraftMatchResponse
  DraftMatchResponse _handleDraftMatchResponse(dynamic data) {
    bool success = true;
    String message = "Success";
    DraftMatchModel? draftMatch;

    // Handle direct string response (like "Interest recorded")
    if (data is String) {
      success = true;
      message = data;
      draftMatch = null;
    } else if (data is Map<String, dynamic>) {
      if (data.containsKey('success')) {
        success = data['success'] ?? true;
      }
      if (data.containsKey('message')) {
        message = data['message'] ?? "Success";
      }
      if (data.containsKey('data') && data['data'] != null) {
        // Check if data is a Map (DraftMatch object) or String (success message)
        if (data['data'] is Map<String, dynamic>) {
          draftMatch = DraftMatchModel.fromJson(data['data'] as Map<String, dynamic>);
        } else if (data['data'] is String) {
          // Handle string responses like "Interest recorded" or "Interest removed"
          print('[API] Received string response: ${data['data']}');
          message = data['data'] as String;
          draftMatch = null;
        }
      }
    }

    final responseMap = {
      'success': success,
      'message': message,
      'data': draftMatch?.toJson(),
    };

    return DraftMatchResponse.fromJson(responseMap);
  }

  // Helper method to handle ConvertToMatch response
  DraftMatchResponse _handleConvertToMatchResponse(dynamic data) {
    bool success = true;
    String message = "Success";

    if (data is Map<String, dynamic>) {
      if (data.containsKey('success')) {
        success = data['success'] ?? true;
      }
      if (data.containsKey('message')) {
        message = data['message'] ?? "Success";
      }
      // For convertToMatch, we don't need to parse the data field as DraftMatchModel
      // since it contains different structure (participantCount, draftMatchId, status)
    }

    final responseMap = {
      'success': success,
      'message': message,
      'data': null, // Set to null since we don't need DraftMatchModel for convert response
    };

    return DraftMatchResponse.fromJson(responseMap);
  }

  @override
  Future<PostResponse> createPost(PostRequest request) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'content': request.content,
        'userId': request.userId,
        if (request.image != null) 'image': request.image,
      });

      print('Creating post with formData: ${formData.fields}');
      if (request.image != null) {
        print('Image file included: ${request.image!.filename}');
      }

      final response = await _apiClient.dio.post(
        ApiConstants.createPostEndpoint,
        data: formData,
      );
      print('Create post response: ${response.data}');
      print('Response status: ${response.statusCode}');

      final postResponse = PostResponse.fromJson(response.data);
      print('Parsed PostResponse imageUrl: ${postResponse.imageUrl}');

      return postResponse;
    } on DioException catch (e) {
      print('DioException in createPost: ${e.message}');
      print('DioException response: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PostResponse>> getPosts(int userId) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.getPostsEndpoint,
        queryParameters: {'userId': userId},
      );
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      if (response.data is! List) {
        throw Exception(
          'Response data is not a List: ${response.data.runtimeType}',
        );
      }
      return (response.data as List)
          .map((post) => PostResponse.fromJson(post))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> likePost(int postId, int userId) async {
    try {
      await _apiClient.dio.put(
        ApiConstants.likePostEndpoint,
        queryParameters: {'postId': postId, 'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CommentResponse>> getCommentsForPost(
    int postId,
    int userId,
  ) async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.getCommentsEndpoint,
        queryParameters: {'postId': postId, 'userId': userId},
      );
      print('Comments Response Data: ${response.data}');
      return (response.data as List)
          .map((comment) => CommentResponse.fromJson(comment))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CommentResponse> createComment(
    int postId,
    int userId,
    CommentRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.createCommentEndpoint,
        queryParameters: {'postId': postId, 'userId': userId},
        data: request.toJson(),
      );
      return CommentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> likeComment(int commentId, int userId) async {
    try {
      await _apiClient.dio.put(
        ApiConstants.likeCommentEndpoint,
        queryParameters: {'commentId': commentId, 'userId': userId},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CommentResponse> replyToComment(
    int parentCommentId,
    ReplyCommentRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.replyCommentEndpoint,
        queryParameters: {'parentCommentId': parentCommentId},
        data: request.toJson(),
      );
      return CommentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, String>> generateAiContent(Uint8List imageBytes) async {
    try {
      final formData = FormData.fromMap({
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: 'image.jpg',
          contentType: DioMediaType('image', 'jpeg'),
        ),
      });

      final response = await _apiClient.dio.post(
        '${ApiConstants.frontendUrl}/api/ai/generate',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return {
          'title': data['title']?.toString() ?? '',
          'content': data['content']?.toString() ?? '',
        };
      } else {
        throw Exception(
          'Failed to generate AI content: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Draft Match implementations
  @override
  Future<DraftMatchResponse> createDraftMatch(
    CreateDraftMatchRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.createDraftMatchEndpoint,
        data: request.toJson(),
      );
      return _handleDraftMatchResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchListResponse> getActiveDraftMatches({
    String? sportType,
    bool? aiRanked,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sportType != null) queryParams['sportType'] = sportType;
      if (aiRanked != null) queryParams['aiRanked'] = aiRanked;

      final response = await _apiClient.dio.get(
        ApiConstants.draftMatchesWithUserInfoEndpoint,
        queryParameters: queryParams,
      );

      // Handle ApiResponse wrapper
      final data = response.data;
      List<dynamic> matches;
      bool success = true;
      String message = "Success";

      if (data is Map<String, dynamic>) {
        if (data.containsKey('success')) {
          success = data['success'] ?? true;
        }
        if (data.containsKey('message')) {
          message = data['message'] ?? "Success";
        }
        if (data.containsKey('data')) {
          // ApiResponse wrapper format
          matches = data['data'] ?? [];
        } else {
          // Assume the whole map is the data
          matches = [];
        }
      } else if (data is List) {
        // Direct array format
        matches = data;
      } else {
        matches = [];
      }

      // Ensure matches is a list
      if (matches is! List) {
        matches = [];
      }

      // Convert matches to DraftMatchModel list
      final draftMatches = matches
          .map((match) => DraftMatchModel.fromJson(match as Map<String, dynamic>))
          .toList();

      // Create response map with expected structure
      final responseMap = {
        'success': success,
        'message': message,
        'data': draftMatches.map((m) => m.toJson()).toList(),
      };

      return DraftMatchListResponse.fromJson(responseMap);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchListResponse> getMyDraftMatches() async {
    try {
      final response = await _apiClient.dio.get(
        ApiConstants.myDraftMatchesEndpoint,
      );

      // Handle ApiResponse wrapper
      final data = response.data;
      List<dynamic> matches;
      bool success = true;
      String message = "Success";

      if (data is Map<String, dynamic>) {
        if (data.containsKey('success')) {
          success = data['success'] ?? true;
        }
        if (data.containsKey('message')) {
          message = data['message'] ?? "Success";
        }
        if (data.containsKey('data')) {
          // ApiResponse wrapper format
          matches = data['data'] ?? [];
        } else {
          // Assume the whole map is the data
          matches = [];
        }
      } else if (data is List) {
        // Direct array format
        matches = data;
      } else {
        matches = [];
      }

      // Ensure matches is a list
      if (matches is! List) {
        matches = [];
      }

      // Convert matches to DraftMatchModel list
      final draftMatches = matches
          .map((match) => DraftMatchModel.fromJson(match as Map<String, dynamic>))
          .toList();

      // Create response map with expected structure
      final responseMap = {
        'success': success,
        'message': message,
        'data': draftMatches.map((m) => m.toJson()).toList(),
      };

      return DraftMatchListResponse.fromJson(responseMap);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchListResponse> getPublicDraftMatches({
    String? sportType,
    bool? aiRanked,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sportType != null) queryParams['sportType'] = sportType;
      if (aiRanked != null) queryParams['aiRanked'] = aiRanked;

      final response = await _apiClient.dio.get(
        ApiConstants.draftMatchesWithUserInfoEndpoint,
        queryParameters: queryParams,
      );

      // Handle ApiResponse wrapper
      final data = response.data;
      List<dynamic> matches;

      if (data is Map<String, dynamic> && data.containsKey('data')) {
        // ApiResponse wrapper format
        matches = data['data'] ?? [];
      } else if (data is List) {
        // Direct array format
        matches = data;
      } else {
        matches = [];
      }

      // Ensure matches is a list
      if (matches is! List) {
        matches = [];
      }

      // Create response map with expected structure
      final responseMap = {
        'matches': matches,
        'totalElements': matches.length,
        'totalPages': 1,
        'currentPage': 0,
      };

      return DraftMatchListResponse.fromJson(responseMap);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> expressInterest(int draftMatchId) async {
    try {
      final endpoint = ApiConstants.expressInterestEndpoint.replaceAll(
        '{id}',
        draftMatchId.toString(),
      );
      final response = await _apiClient.dio.post(endpoint);
      return _handleDraftMatchResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> withdrawInterest(int draftMatchId) async {
    try {
      final endpoint = ApiConstants.withdrawInterestEndpoint.replaceAll(
        '{id}',
        draftMatchId.toString(),
      );
      final response = await _apiClient.dio.delete(endpoint);
      return _handleDraftMatchResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> acceptUser(int draftMatchId, int userId) async {
    try {
      final endpoint = ApiConstants.acceptUserEndpoint
          .replaceAll('{id}', draftMatchId.toString())
          .replaceAll('{userId}', userId.toString());
      final response = await _apiClient.dio.post(endpoint);
      return DraftMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> rejectUser(int draftMatchId, int userId) async {
    try {
      final endpoint = ApiConstants.rejectUserEndpoint
          .replaceAll('{id}', draftMatchId.toString())
          .replaceAll('{userId}', userId.toString());
      final response = await _apiClient.dio.post(endpoint);
      return DraftMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> convertToMatch(int draftMatchId) async {
    try {
      final endpoint = ApiConstants.convertToMatchEndpoint.replaceAll(
        '{id}',
        draftMatchId.toString(),
      );
      final response = await _apiClient.dio.post(endpoint, data: {});
      return _handleConvertToMatchResponse(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> updateDraftMatch(
    int draftMatchId,
    CreateDraftMatchRequest request,
  ) async {
    try {
      final endpoint = ApiConstants.updateDraftMatchEndpoint.replaceAll(
        '{id}',
        draftMatchId.toString(),
      );
      final response = await _apiClient.dio.put(
        endpoint,
        data: request.toJson(),
      );
      return DraftMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UserModel>> getInterestedUsers(int draftMatchId) async {
    try {
      final endpoint = ApiConstants.interestedUsersEndpoint.replaceAll(
        '{id}',
        draftMatchId.toString(),
      );
      final response = await _apiClient.dio.get(endpoint);
      return (response.data as List)
          .map((user) => UserModel.fromJson(user))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchListResponse> getRankedDraftMatches({
    String? sportType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sportType != null) queryParams['sportType'] = sportType;

      final response = await _apiClient.dio.get(
        ApiConstants.rankedDraftMatchesEndpoint,
        queryParameters: queryParams,
      );

      // Handle ApiResponse wrapper
      final data = response.data;
      List<dynamic> matches;
      bool success = true;
      String message = "Success";

      if (data is Map<String, dynamic>) {
        if (data.containsKey('success')) {
          success = data['success'] ?? true;
        }
        if (data.containsKey('message')) {
          message = data['message'] ?? "Success";
        }
        if (data.containsKey('data')) {
          // ApiResponse wrapper format
          matches = data['data'] ?? [];
        } else {
          // Assume the whole map is the data
          matches = [];
        }
      } else if (data is List) {
        // Direct array format
        matches = data;
      } else {
        matches = [];
      }

      // Ensure matches is a list
      if (matches is! List) {
        matches = [];
      }

      // Convert matches to DraftMatchModel list
      final draftMatches = matches
          .map((match) => DraftMatchModel.fromJson(match as Map<String, dynamic>))
          .toList();

      // Create response map with expected structure
      final responseMap = {
        'success': success,
        'message': message,
        'data': draftMatches.map((m) => m.toJson()).toList(),
      };

      return DraftMatchListResponse.fromJson(responseMap);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchListResponse> getDraftMatchesWithUserInfo({
    String? sportType,
    bool? aiRanked,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sportType != null) queryParams['sportType'] = sportType;
      if (aiRanked != null) queryParams['aiRanked'] = aiRanked;

      final response = await _apiClient.dio.get(
        ApiConstants.draftMatchesWithUserInfoEndpoint,
        queryParameters: queryParams,
      );

      // Handle ApiResponse wrapper
      final data = response.data;
      List<dynamic> matches;
      bool success = true;
      String message = "Success";

      if (data is Map<String, dynamic>) {
        if (data.containsKey('success')) {
          success = data['success'] ?? true;
        }
        if (data.containsKey('message')) {
          message = data['message'] ?? "Success";
        }
        if (data.containsKey('data')) {
          // ApiResponse wrapper format
          matches = data['data'] ?? [];
        } else {
          // Assume the whole map is the data
          matches = [];
        }
      } else if (data is List) {
        // Direct array format
        matches = data;
      } else {
        matches = [];
      }

      // Ensure matches is a list
      if (matches is! List) {
        matches = [];
      }

      // Convert matches to DraftMatchModel list
      final draftMatches = matches
          .map((match) => DraftMatchModel.fromJson(match as Map<String, dynamic>))
          .toList();

      // Create response map with expected structure
      final responseMap = {
        'success': success,
        'message': message,
        'data': draftMatches.map((m) => m.toJson()).toList(),
      };

      return DraftMatchListResponse.fromJson(responseMap);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> initiateDraftMatchBooking(
    int draftMatchId,
    Map<String, dynamic> bookingData,
  ) async {
    try {
      final endpoint = ApiConstants.initiateDraftMatchBookingEndpoint
          .replaceAll('{id}', draftMatchId.toString());
      final response = await _apiClient.dio.post(endpoint, data: bookingData);
      return DraftMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<DraftMatchResponse> completeDraftMatchBooking(
    int draftMatchId,
    int bookingId,
  ) async {
    try {
      final endpoint = ApiConstants.completeDraftMatchBookingEndpoint
          .replaceAll('{draftMatchId}', draftMatchId.toString());
      final response = await _apiClient.dio.post(
        '$endpoint?bookingId=$bookingId',
      );
      return DraftMatchResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    print('Full DioException: $e');

    if (e.response != null) {
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');
      print('Response status code: ${e.response?.statusCode}');

      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      switch (statusCode) {
        case 400:
          final message = responseData?['message'] ?? 'Yêu cầu không hợp lệ';
          return Exception('BAD_REQUEST: $message');
        case 401:
          return Exception('UNAUTHORIZED: Phiên đăng nhập đã hết hạn');
        case 403:
          return Exception(
            'FORBIDDEN: Bạn không có quyền thực hiện thao tác này',
          );
        case 404:
          return Exception('NOT_FOUND: Không tìm thấy dữ liệu');
        case 500:
          final message = responseData?['message'] ?? 'Lỗi máy chủ nội bộ';
          return Exception(
            'SERVER_ERROR: Máy chủ đang gặp sự cố. Vui lòng thử lại sau. ($message)',
          );
        case 502:
          return Exception(
            'BAD_GATEWAY: Máy chủ không phản hồi. Vui lòng thử lại sau.',
          );
        case 503:
          return Exception(
            'SERVICE_UNAVAILABLE: Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.',
          );
        default:
          final message = responseData?['message'] ?? 'Đã xảy ra lỗi';
          return Exception('HTTP_ERROR_$statusCode: $message');
      }
    } else {
      print('Request options: ${e.requestOptions}');
      print('Error type: ${e.type}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception(
            'TIMEOUT: Kết nối mạng bị gián đoạn. Vui lòng kiểm tra kết nối và thử lại.',
          );
        case DioExceptionType.connectionError:
          return Exception(
            'CONNECTION_ERROR: Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
          );
        case DioExceptionType.cancel:
          return Exception('CANCELLED: Yêu cầu đã bị hủy');
        default:
          return Exception(
            'NETWORK_ERROR: Lỗi mạng không xác định. Vui lòng thử lại.',
          );
      }
    }
  }
}
