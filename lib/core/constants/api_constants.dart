import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:1444/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:1444/api';
    }
    return 'http://localhost:1444/api';
  }

  static String get aiServiceUrl {
    if (kIsWeb) {
      return 'http://192.168.1.4:5002';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.4:5002';
    } else if (Platform.isIOS) {
      return 'http://192.168.1.4:5002';
    } else {
      return 'http://192.168.1.4:5002';
    }
  }

  static const String authEndpoint = '/auth';
  
  // Auth endpoints
  static const String loginEndpoint = '$authEndpoint/signin';
  static const String registerEndpoint = '$authEndpoint/signup';
  static const String googleAuthEndpoint = '$authEndpoint/oauth2/google';
  static const String refreshTokenEndpoint = '$authEndpoint/refreshtoken';
  static const String forgotPasswordEndpoint = '$authEndpoint/forgot-password';
  static const String resetPasswordEndpoint = '$authEndpoint/reset-password';
  
  // Location endpoints
  static const String locationsEndpoint = '/locations';
  static const String mapDataEndpoint = '/locations/map-data';
  
  // Booking endpoints
  static const String bookingsEndpoint = '/bookings';
  static const String fieldsEndpoint = '/fields';
  
  // Match endpoints
  static const String matchesEndpoint = '/matches';
  static const String openMatchesEndpoint = '/open-matches';
  static const String rankedMatchesEndpoint = '/open-matches/ranked';
  
  // Chat endpoints
  static const String chatRoomsEndpoint = '/chat-rooms';
  static const String chatRoomsCreateEndpoint = '/chat-rooms';

  static const String chatRoomsLeaveEndpoint = '/chat-rooms/{roomId}/leave';
  static const String chatRoomsMembersEndpoint = '/chat-rooms/{chatRoomId}/members';
  static const String chatRoomsMessagesEndpoint = '/chat-rooms/{roomId}/messages';
  static const String chatRoomsDeleteMessageEndpoint = '/chat-rooms/{roomId}/messages/{messageId}';
  static const String chatRoomsInviteEndpoint = '/chat-rooms/{chatRoomId}/members/by-email';
  static const String chatRoomsRemoveMemberEndpoint = '/chat-rooms/{roomId}/remove-member/{userId}';
  static const String chatRoomsDeleteEndpoint = '/chat-rooms/{roomId}';
  static const String chatRoomsAddMemberEndpoint = '/chat-rooms/{roomId}/members';
  static const String chatRoomsClearMessagesEndpoint = '/chat-rooms/{roomId}/messages';
  
  // User endpoints
  static const String usersEndpoint = '/auth/users';
  
  // Chatbot endpoints (Backend API)
  static const String chatbotQueryEndpoint = '/chatbot/query';
  static const String chatbotHealthEndpoint = '/chatbot/health';

  // Community endpoints
  static const String getPostsEndpoint = '/posts';
  static const String createPostEndpoint = '/posts';
  static const String likePostEndpoint = '/posts/like';
  static const String getCommentsEndpoint = '/comments';
  static const String createCommentEndpoint = 'comments';
  static const String likeCommentEndpoint = '/comments/like';
  static const String replyCommentEndpoint = '/comments/reply';
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static const String bearer = 'Bearer';
  
  // Default headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': contentType,
    'Accept': contentType,
  };
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds
}