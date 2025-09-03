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
    // Handle backend response structure
    return OpenMatchJoinRequestModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      openMatch: _createOpenMatchFromBackendResponse(
        json['openMatch'] as Map<String, dynamic>,
      ),
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  static OpenMatchModel _createOpenMatchFromBackendResponse(
    Map<String, dynamic> openMatchData,
  ) {
    return OpenMatchModel(
      id: openMatchData['id'] as int,
      fieldName: openMatchData['fieldName'] as String? ?? '',
      locationName: openMatchData['locationName'] as String? ?? '',
      fieldAddress: openMatchData['fieldAddress'] as String? ?? '',
      startTime: DateTime.parse(openMatchData['startTime'] as String),
      endTime: DateTime.parse(openMatchData['endTime'] as String),
      currentPlayers: openMatchData['currentPlayers'] as int? ?? 0,
      maxPlayers: openMatchData['maxPlayers'] as int? ?? 0,
      pricePerPerson:
          (openMatchData['pricePerPerson'] as num?)?.toDouble() ?? 0.0,
      description: openMatchData['description'] as String?,
      fieldImageUrl: openMatchData['fieldImageUrl'] as String?,
      compatibilityScore: (openMatchData['compatibilityScore'] as num?)
          ?.toDouble(),
      creatorUserName: openMatchData['creatorUserName'] as String?,
      creatorAvatarUrl: openMatchData['creatorAvatarUrl'] as String?,
      requiredTags:
          (openMatchData['requiredTags'] as List<dynamic>?)?.cast<String>() ??
          [],
      skillLevel: openMatchData['skillLevel'] as String? ?? 'intermediate',
      gameType: openMatchData['gameType'] as String? ?? 'football',
      creatorUserId: openMatchData['creatorUserId'] as String?,
    );
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

  factory OpenMatchJoinRequestListResponse.fromJson(Map<String, dynamic> json) {
    return OpenMatchJoinRequestListResponse(
      requests:
          (json['requests'] as List<dynamic>?)
              ?.map(
                (e) => OpenMatchJoinRequestModel.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
    );
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
