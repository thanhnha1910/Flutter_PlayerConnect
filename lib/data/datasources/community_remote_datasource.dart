import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/constants/api_constants.dart';
import 'package:player_connect/core/network/api_client.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/data/models/post_models.dart';

abstract class CommunityRemoteDataSource {
  Future<List<PostResponse>> getPosts(int userId);
  Future<PostResponse> createPost(PostRequest request);
  Future<void> likePost(int postId, int userId);
  Future<List<CommentResponse>> getCommentsForPost(int postId, int userId);
  Future<CommentResponse> createComment(int postId, int userId, CommentRequest request);
  Future<void> likeComment(int commentId, int userId);
  Future<CommentResponse> replyToComment(int parentCommentId, ReplyCommentRequest request);
}

@LazySingleton(as: CommunityRemoteDataSource)
class CommunityRemoteDataSourceImpl implements CommunityRemoteDataSource {
  final ApiClient _apiClient;

  CommunityRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  @override
  Future<PostResponse> createPost(PostRequest request) async {
    try {
      final formData = FormData.fromMap({
        'title': request.title,
        'content': request.content,
        'userId': request.userId,
        if (request.image != null) 'image': request.image,
      });

      final response = await _apiClient.dio.post(ApiConstants.createPostEndpoint, data: formData);
      return PostResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<PostResponse>> getPosts(int userId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.baseUrl}${ApiConstants.getPostsEndpoint}', queryParameters: {'userId': userId});
      if (response.data == null) {
        throw Exception('Response data is null');
      }
      if (response.data is! List) {
        throw Exception('Response data is not a List: ${response.data.runtimeType}');
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
      await _apiClient.dio.put('${ApiConstants.baseUrl}${ApiConstants.likePostEndpoint}', queryParameters: {'postId': postId, 'userId': userId});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CommentResponse>> getCommentsForPost(int postId, int userId) async {
    try {
      final response = await _apiClient.dio.get('${ApiConstants.baseUrl}${ApiConstants.getCommentsEndpoint}', queryParameters: {'postId': postId, 'userId': userId});
      print('Comments Response Data: ${response.data}');
      return (response.data as List)
          .map((comment) => CommentResponse.fromJson(comment))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CommentResponse> createComment(int postId, int userId, CommentRequest request) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.baseUrl}${ApiConstants.createCommentEndpoint}', queryParameters: {'postId': postId, 'userId': userId}, data: request.toJson());
      return CommentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> likeComment(int commentId, int userId) async {
    try {
      await _apiClient.dio.put('${ApiConstants.baseUrl}${ApiConstants.likeCommentEndpoint}', queryParameters: {'commentId': commentId, 'userId': userId});
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<CommentResponse> replyToComment(int parentCommentId, ReplyCommentRequest request) async {
    try {
      final response = await _apiClient.dio.post('${ApiConstants.baseUrl}${ApiConstants.replyCommentEndpoint}', queryParameters: {'parentCommentId': parentCommentId}, data: request.toJson());
      return CommentResponse.fromJson(response.data);
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
      final message = e.response?.data['message'] ?? 'Đã xảy ra lỗi';
      return Exception(message);
    } else {
      print('Request options: ${e.requestOptions}');
      print('Error type: ${e.type}');
      return Exception('Không thể kết nối đến máy chủ');
    }
  }
}