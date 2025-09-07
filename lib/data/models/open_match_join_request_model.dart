import 'user_model.dart';
import 'open_match_model.dart';

class OpenMatchJoinRequestModel {
  final int id;
  final UserModel user;
  final OpenMatchModel openMatch;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const OpenMatchJoinRequestModel({
    required this.id,
    required this.user,
    required this.openMatch,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  factory OpenMatchJoinRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle backend response structure - invitations API returns flat structure
    try {
      return OpenMatchJoinRequestModel(
        id: json['id'] as int? ?? 0,
        user: _createUserFromInvitationResponse(json),
        openMatch: _createOpenMatchFromInvitationResponse(json),
        status: json['status'] as String? ?? 'PENDING',
        message: json['message'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
            : DateTime.now(),
        respondedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
      );
    } catch (e) {
      print('Error parsing OpenMatchJoinRequestModel: $e');
      print('JSON data: $json');
      // Return a default object to prevent crashes
      return OpenMatchJoinRequestModel(
        id: 0,
        user: UserModel(
          id: 0,
          username: 'Unknown',
          email: '',
          fullName: 'Unknown User',
          roles: ['USER'],
          status: 'ACTIVE',
          hasCompletedProfile: false,
        ),
        openMatch: OpenMatchModel(
          id: 0,
          fieldName: 'Unknown Field',
          locationName: 'Unknown Location',
          fieldAddress: '',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 2)),
          currentPlayers: 0,
          maxPlayers: 0,
          pricePerPerson: 0.0,
          skillLevel: 'intermediate',
          gameType: 'football',
        ),
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
    }
  }

  // Map sport type từ backend format sang frontend format
  static String _mapSportType(String? sportType) {
    if (sportType == null) return 'football';
    
    switch (sportType.toUpperCase()) {
      case 'BONG_DA':
      case 'FOOTBALL':
        return 'football';
      case 'BONG_RO':
      case 'BASKETBALL':
        return 'basketball';
      case 'TENNIS':
        return 'tennis';
      case 'BADMINTON':
        return 'badminton';
      default:
        return sportType.toLowerCase();
    }
  }

  static UserModel _createUserFromInvitationResponse(Map<String, dynamic> json) {
    // Create UserModel from invitation flat structure
    try {
      // Ensure all required fields have non-null values
      final id = json['inviteeId'] as int? ?? 0;
      final name = json['inviteeName'] as String? ?? 'Unknown User';
      final username = name.isNotEmpty ? name : 'Unknown User';
      final fullName = name.isNotEmpty ? name : 'Unknown User';
      
      // Create a properly formatted JSON for UserModel.fromJson
      final userJson = {
        'id': id,
        'username': username,
        'email': '', // Not provided in invitation response
        'fullName': fullName,
        'profilePicture': json['inviteeProfilePicture'],
        'roles': ['ROLE_USER'], // Default role
        'status': 'ACTIVE', // Default status
        'hasCompletedProfile': true, // Assume completed
      };
      
      return UserModel.fromJson(userJson);
    } catch (e) {
      print('Error creating UserModel from invitation response: $e');
      print('JSON data: $json');
      // Return a safe default UserModel
      final defaultUserJson = {
        'id': 0,
        'username': 'Unknown User',
        'email': '',
        'fullName': 'Unknown User',
        'roles': ['ROLE_USER'],
        'status': 'ACTIVE',
        'hasCompletedProfile': false,
      };
      return UserModel.fromJson(defaultUserJson);
    }
  }

  static OpenMatchModel _createOpenMatchFromInvitationResponse(Map<String, dynamic> json) {
    // Create OpenMatchModel from invitation flat structure
    try {
      // Parse datetime safely
      DateTime startTime = DateTime.now();
      if (json['matchDateTime'] != null) {
        final dateTimeStr = json['matchDateTime'] as String;
        startTime = DateTime.tryParse(dateTimeStr) ?? DateTime.now();
      }
      DateTime endTime = startTime.add(Duration(hours: 2));
      
      // Create a properly formatted JSON for OpenMatchModel.fromJson
      final openMatchJson = {
        'id': json['openMatchId'] as int? ?? 0,
        'fieldName': json['fieldName'] as String? ?? 'Unknown Field',
        'locationName': json['fieldName'] as String? ?? 'Unknown Location',
        'fieldAddress': '', // Not provided in invitation response
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'currentPlayers': 0, // Not provided in invitation response
        'maxPlayers': 0, // Not provided in invitation response
        'pricePerPerson': 0.0, // Not provided in invitation response
        'description': json['openMatchTitle'] as String?,
        'fieldImageUrl': null,
        'compatibilityScore': null,
        'creatorUserName': json['inviterName'] as String?,
        'creatorAvatarUrl': json['inviterProfilePicture'] as String?,
        'requiredTags': [],
        'skillLevel': 'intermediate',
        'gameType': _mapSportType(json['sportType'] as String?),
        'creatorUserId': json['inviterId']?.toString(),
        'isCreator': false,
      };
      
      return OpenMatchModel.fromJson(openMatchJson);
    } catch (e) {
      print('Error creating OpenMatchModel from invitation response: $e');
      print('JSON data: $json');
      // Return a safe default OpenMatchModel
      final defaultOpenMatchJson = {
        'id': 0,
        'fieldName': 'Unknown Field',
        'locationName': 'Unknown Location',
        'fieldAddress': '',
        'startTime': DateTime.now().toIso8601String(),
        'endTime': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
        'currentPlayers': 0,
        'maxPlayers': 0,
        'pricePerPerson': 0.0,
        'skillLevel': 'intermediate',
        'gameType': 'football',
        'isCreator': false,
      };
      return OpenMatchModel.fromJson(defaultOpenMatchJson);
    }
  }



  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'openMatch': openMatch.toJson(),
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String get displayTitle => 'Yêu cầu tham gia trận đấu mở';
  String get displaySubtitle =>
      '${openMatch.gameType} - ${openMatch.locationName}';
}

class OpenMatchJoinRequestListResponse {
  final List<OpenMatchJoinRequestModel> requests;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const OpenMatchJoinRequestListResponse({
    required this.requests,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OpenMatchJoinRequestListResponse.fromJson(dynamic json) {
    // Handle both array response and object response
    if (json is List<dynamic>) {
      // Direct array response from invitations API
      return OpenMatchJoinRequestListResponse(
        requests: json
            .where((e) => e != null) // Filter out null elements
            .map(
              (e) {
                try {
                  return OpenMatchJoinRequestModel.fromJson(
                    e as Map<String, dynamic>,
                  );
                } catch (error) {
                  print('Error parsing individual request: $error');
                  print('Request data: $e');
                  return null;
                }
              },
            )
            .where((e) => e != null) // Filter out failed parsing
            .cast<OpenMatchJoinRequestModel>()
            .toList(),
        totalElements: json.length,
        totalPages: 1,
        currentPage: 0,
      );
    } else if (json is Map<String, dynamic>) {
      // Object response with pagination info
      return OpenMatchJoinRequestListResponse(
        requests:
            (json['requests'] as List<dynamic>?)
                ?.where((e) => e != null) // Filter out null elements
                ?.map(
                  (e) {
                    try {
                      return OpenMatchJoinRequestModel.fromJson(
                        e as Map<String, dynamic>,
                      );
                    } catch (error) {
                      print('Error parsing individual request: $error');
                      print('Request data: $e');
                      return null;
                    }
                  },
                )
                ?.where((e) => e != null) // Filter out failed parsing
                ?.cast<OpenMatchJoinRequestModel>()
                ?.toList() ??
            [],
        totalElements: json['totalElements'] as int? ?? 0,
        totalPages: json['totalPages'] as int? ?? 0,
        currentPage: json['currentPage'] as int? ?? 0,
      );
    } else {
      // Fallback for null or unexpected response
      print('Unexpected response type: ${json.runtimeType}');
      print('Response data: $json');
      return const OpenMatchJoinRequestListResponse(
        requests: [],
        totalElements: 0,
        totalPages: 0,
        currentPage: 0,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'requests': requests.map((e) => e.toJson()).toList(),
      'totalElements': totalElements,
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }
}

class SendOpenMatchJoinRequestModel {
  final String message;

  const SendOpenMatchJoinRequestModel({required this.message});

  factory SendOpenMatchJoinRequestModel.fromJson(Map<String, dynamic> json) {
    return SendOpenMatchJoinRequestModel(message: json['message'] as String);
  }

  Map<String, dynamic> toJson() {
    return {'message': message};
  }
}
