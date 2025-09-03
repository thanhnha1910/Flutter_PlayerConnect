import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://192.168.1.12:1444/api';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.12:1444/api';
    }
    return 'http://192.168.1.12:1444/api';
  }

  static String get aiServiceUrl {
    if (kIsWeb) {
      return 'http://localhost:5002';
    } else if (Platform.isAndroid) {
      return 'http://localhost:5002';
    } else if (Platform.isIOS) {
      return 'http://localhost:5002';
    } else {
      return 'http://localhost:5002';
    }
  }

  static String get frontendUrl {
    if (kIsWeb) {
      return 'http://192.168.1.12:3000';
    } else if (Platform.isAndroid) {
      return 'http://192.168.1.12:3000';
    } else if (Platform.isIOS) {
      return 'http://192.168.1.12:3000';
    } else {
      return 'http://192.168.1.12:3000';
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
  static const String joinOpenMatchEndpoint = '/open-matches/{id}/join-request';
  static const String leaveOpenMatchEndpoint = '/open-matches/{id}/leave';

  // Chat endpoints
  static const String chatRoomsEndpoint = '/chat-rooms';
  static const String chatRoomsCreateEndpoint = '/chat-rooms';

  static const String chatRoomsLeaveEndpoint = '/chat-rooms/{roomId}/leave';
  static const String chatRoomsMembersEndpoint =
      '/chat-rooms/{chatRoomId}/members';
  static const String chatRoomsMessagesEndpoint =
      '/chat-rooms/{roomId}/messages';
  static const String chatRoomsDeleteMessageEndpoint =
      '/chat-rooms/{roomId}/messages/{messageId}';
  static const String chatRoomsInviteEndpoint =
      '/chat-rooms/{chatRoomId}/members/by-email';
  static const String chatRoomsRemoveMemberEndpoint =
      '/chat-rooms/{roomId}/remove-member/{userId}';
  static const String chatRoomsDeleteEndpoint = '/chat-rooms/{roomId}';
  static const String chatRoomsAddMemberEndpoint =
      '/chat-rooms/{roomId}/members';
  static const String chatRoomsClearMessagesEndpoint =
      '/chat-rooms/{roomId}/messages';

  // User endpoints
  static const String usersEndpoint = '/auth/users';
  static const String userProfileEndpoint = '/user/profile';
  static const String userBookingsEndpoint = '/user/bookings';
  static const String changePasswordEndpoint = '/user/change-password';

  // Chatbot endpoints (Backend API)
  static const String chatbotQueryEndpoint = '/chatbot/query';
  static const String chatbotHealthEndpoint = '/chatbot/health';
  //community
  static const String getPostsEndpoint = '/posts';
  static const String createPostEndpoint = '/posts';
  static const String likePostEndpoint = '/posts/like';
  static const String getCommentsEndpoint = '/comments';
  static const String createCommentEndpoint = '/comments';
  static const String likeCommentEndpoint = '/comments/like';
  static const String replyCommentEndpoint = '/comments/reply';

  // AI endpoints
  static const String aiGenerateEndpoint = '/ai/generate';

  // Draft Match endpoints
  static const String draftMatchesEndpoint = '/draft-matches';
  static const String createDraftMatchEndpoint = '/draft-matches';
  static const String activeDraftMatchesEndpoint = '/draft-matches';
  static const String myDraftMatchesEndpoint = '/draft-matches/my-drafts';
  static const String publicDraftMatchesEndpoint = '/draft-matches/public';
  static const String expressInterestEndpoint =
      '/draft-matches/{id}/express-interest';
  static const String withdrawInterestEndpoint =
      '/draft-matches/{id}/withdraw-interest';
  static const String acceptUserEndpoint =
      '/draft-matches/{id}/accept-user/{userId}';
  static const String rejectUserEndpoint =
      '/draft-matches/{id}/reject-user/{userId}';
  static const String convertToMatchEndpoint =
      '/draft-matches/{id}/convert-to-match';
  static const String updateDraftMatchEndpoint = '/draft-matches/{id}';
  static const String interestedUsersEndpoint =
      '/draft-matches/{id}/interested-users';
  static const String initiateDraftMatchBookingEndpoint =
      '/draft-matches/{id}/initiate-booking';
  static const String completeDraftMatchBookingEndpoint =
      '/booking/from-draft/{draftMatchId}';
  static const String rankedDraftMatchesEndpoint = '/draft-matches/ranked';
  static const String draftMatchesWithUserInfoEndpoint =
      '/draft-matches/with-user-info';
  static const String receivedDraftMatchRequestsEndpoint =
      '/draft-matches/received-requests';
  static const String sentDraftMatchRequestsEndpoint =
      '/draft-matches/sent-requests';

  // AI Recommendation endpoints
  static const String aiRecommendTeammatesEndpoint =
      '/booking/{id}/recommend-teammates';

  // Invitation endpoints
  static const String invitationsEndpoint = '/invitations';
  static const String receivedInvitationsEndpoint = '/invitations/received';
  static const String sentInvitationsEndpoint = '/invitations/sent';
  static const String respondToInvitationEndpoint = '/invitations/{id}/respond';
  static const String playerInvitationEndpoint = '/invitations/player/{id}';
  static const String teamInviteEndpoint = '/teams/{teamId}/invite';

  // Tournament endpoints
  static const String tournamentsEndpoint = '/tournament';
  static const String tournamentRegisterEndpoint = '/tournament/register';
  static const String tournamentBySlugEndpoint = '/tournament/slug/{slug}';
  static const String tournamentReceiptEndpoint =
      '/tournament/receipt/{tournamentId}';
  static const String tournamentPublicReceiptEndpoint =
      '/tournament/public-receipt/{tournamentId}';

  // Team endpoints
  static const String teamsEndpoint = '/teams';
  static const String teamsByUserEndpoint =
      '/teams'; // Use query parameter ?userId={userId}
  static const String createTeamEndpoint = '/teams';

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
