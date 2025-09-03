import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';
import 'team_model.dart';
import 'draft_match_model.dart';

part 'invitation_model.g.dart';

@JsonSerializable()
class InvitationModel {
  final int id;
  final String type; // 'TEAM_INVITATION' or 'DRAFT_MATCH_REQUEST'
  final String status; // 'PENDING', 'ACCEPTED', 'REJECTED'
  final UserModel sender;
  final UserModel? receiver;
  final TeamModel? team;
  final DraftMatchModel? draftMatch;
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const InvitationModel({
    required this.id,
    required this.type,
    required this.status,
    required this.sender,
    this.receiver,
    this.team,
    this.draftMatch,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  factory InvitationModel.fromJson(Map<String, dynamic> json) =>
      _$InvitationModelFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationModelToJson(this);

  bool get isTeamInvitation => type == 'TEAM_INVITATION';
  bool get isDraftMatchRequest => type == 'DRAFT_MATCH_REQUEST';
  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';

  String get displayTitle {
    if (isTeamInvitation && team != null) {
      return 'Lời mời tham gia đội ${team!.name}';
    } else if (isDraftMatchRequest && draftMatch != null) {
      return 'Yêu cầu tham gia trận đấu';
    }
    return 'Lời mời';
  }

  String get displaySubtitle {
    if (isTeamInvitation) {
      return 'Từ ${sender.fullName}';
    } else if (isDraftMatchRequest && draftMatch != null) {
      return '${draftMatch!.sportType} - ${draftMatch!.locationDescription}';
    }
    return '';
  }
}

@JsonSerializable()
class InvitationListResponse {
  final List<InvitationModel> invitations;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const InvitationListResponse({
    required this.invitations,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory InvitationListResponse.fromJson(Map<String, dynamic> json) {
    return InvitationListResponse(
      invitations: (json['invitations'] as List<dynamic>?)
          ?.map((e) => InvitationModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$InvitationListResponseToJson(this);
}

@JsonSerializable()
class InvitationActionRequest {
  final String action; // 'ACCEPT' or 'REJECT'
  final String? message;

  const InvitationActionRequest({
    required this.action,
    this.message,
  });

  factory InvitationActionRequest.fromJson(Map<String, dynamic> json) =>
      _$InvitationActionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$InvitationActionRequestToJson(this);
}

@JsonSerializable()
class DraftMatchRequestModel {
  final int id;
  final UserModel user;
  final DraftMatchModel draftMatch;
  final String status; // 'PENDING', 'APPROVED', 'REJECTED'
  final String? message;
  final DateTime createdAt;
  final DateTime? respondedAt;

  const DraftMatchRequestModel({
    required this.id,
    required this.user,
    required this.draftMatch,
    required this.status,
    this.message,
    required this.createdAt,
    this.respondedAt,
  });

  factory DraftMatchRequestModel.fromJson(Map<String, dynamic> json) {
    // Handle backend response structure
    return DraftMatchRequestModel(
      id: json['id'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      draftMatch: _createDraftMatchFromBackendResponse(json['draftMatch'] as Map<String, dynamic>),
      status: json['status'] as String,
      message: json['message'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String) 
          : null,
    );
  }

  static DraftMatchModel _createDraftMatchFromBackendResponse(Map<String, dynamic> draftMatchData) {
    return DraftMatchModel(
      id: draftMatchData['id'] as int,
      creatorUserId: 0, // Will be set from creator data if available
      creatorUserName: '', // Will be set from creator data if available
      creatorAvatarUrl: null,
      sportType: draftMatchData['sportType'] as String,
      locationDescription: draftMatchData['locationDescription'] as String,
      estimatedStartTime: DateTime.parse(draftMatchData['estimatedStartTime'] as String),
      estimatedEndTime: DateTime.parse(draftMatchData['estimatedEndTime'] as String),
      slotsNeeded: draftMatchData['slotsNeeded'] as int,
      skillLevel: draftMatchData['skillLevel'] as String,
      requiredTags: [], // Backend doesn't provide this in request response
      status: 'RECRUITING', // Default status
      createdAt: DateTime.now(), // Backend doesn't provide this in request response
      interestedUsersCount: 0,
      interestedUserIds: [],
      pendingUsersCount: 0,
      approvedUsersCount: 0,
      userStatuses: [],
      currentUserInterested: false,
      currentUserStatus: null,
    );
  }

  Map<String, dynamic> toJson() => _$DraftMatchRequestModelToJson(this);

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  String get displayTitle => 'Yêu cầu tham gia trận đấu';
  String get displaySubtitle => '${draftMatch.sportType} - ${draftMatch.locationDescription}';
}

@JsonSerializable()
class DraftMatchRequestListResponse {
  final List<DraftMatchRequestModel> requests;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const DraftMatchRequestListResponse({
    required this.requests,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory DraftMatchRequestListResponse.fromJson(Map<String, dynamic> json) {
    return DraftMatchRequestListResponse(
      requests: (json['requests'] as List<dynamic>?)
          ?.map((e) => DraftMatchRequestModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      currentPage: json['currentPage'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => _$DraftMatchRequestListResponseToJson(this);
}