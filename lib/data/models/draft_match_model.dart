import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'draft_match_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DraftMatchModel extends Equatable {
  final int id;
  final int creatorUserId;
  final String creatorUserName;
  final String? creatorAvatarUrl;
  final String sportType;
  final String locationDescription;
  final DateTime estimatedStartTime;
  final DateTime estimatedEndTime;
  final int slotsNeeded;
  final String skillLevel;
  final List<String> requiredTags;
  final String status;
  final DateTime createdAt;
  final int interestedUsersCount;
  final List<int> interestedUserIds;
  final int pendingUsersCount;
  final int approvedUsersCount;
  final List<Map<String, dynamic>> userStatuses;
  final bool? currentUserInterested;
  final String? currentUserStatus;
  final double? compatibilityScore;
  final double? explicitScore;
  final double? implicitScore;
  final double? baseCompatibilityScore;
  final double? originalAIScore;
  final bool? scoreValidated;
  final bool? aiScoreUsed;

  const DraftMatchModel({
    required this.id,
    required this.creatorUserId,
    required this.creatorUserName,
    this.creatorAvatarUrl,
    required this.sportType,
    required this.locationDescription,
    required this.estimatedStartTime,
    required this.estimatedEndTime,
    required this.slotsNeeded,
    required this.skillLevel,
    required this.requiredTags,
    required this.status,
    required this.createdAt,
    required this.interestedUsersCount,
    required this.interestedUserIds,
    required this.pendingUsersCount,
    required this.approvedUsersCount,
    required this.userStatuses,
    this.currentUserInterested,
    this.currentUserStatus,
    this.compatibilityScore,
    this.explicitScore,
    this.implicitScore,
    this.baseCompatibilityScore,
    this.originalAIScore,
    this.scoreValidated,
    this.aiScoreUsed,
  });

  factory DraftMatchModel.fromJson(Map<String, dynamic> json) =>
      _$DraftMatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$DraftMatchModelToJson(this);

  // Helper getters
  int get approvedSlotsCount => approvedUsersCount;
  int get remainingSlotsCount => slotsNeeded - approvedSlotsCount;
  bool get isFull => approvedSlotsCount >= slotsNeeded;
  bool get isActive => status == 'RECRUITING';

  // Duration helper
  Duration get estimatedDuration =>
      estimatedEndTime.difference(estimatedStartTime);

  // Sport type display helper
  String get sportTypeDisplay {
    switch (sportType) {
      case 'BONG_DA':
        return 'Bóng đá';
      case 'BONG_RO':
        return 'Bóng rổ';
      case 'CAU_LONG':
        return 'Cầu lông';
      case 'TENNIS':
        return 'Tennis';
      case 'BONG_BAN':
        return 'Bóng bàn';
      case 'BONG_CHUYEN':
        return 'Bóng chuyền';
      default:
        return sportType;
    }
  }

  // Skill level display helper
  String get skillLevelDisplay {
    switch (skillLevel) {
      case 'BEGINNER':
        return 'Mới bắt đầu';
      case 'INTERMEDIATE':
        return 'Trung bình';
      case 'ADVANCED':
        return 'Khá giỏi';
      case 'EXPERT':
        return 'Chuyên nghiệp';
      case 'ANY':
        return 'Tất cả trình độ';
      default:
        return skillLevel;
    }
  }

  // Copy with method for optimistic updates
  DraftMatchModel copyWith({
    int? id,
    int? creatorUserId,
    String? creatorUserName,
    String? creatorAvatarUrl,
    String? sportType,
    String? locationDescription,
    DateTime? estimatedStartTime,
    DateTime? estimatedEndTime,
    int? slotsNeeded,
    String? skillLevel,
    List<String>? requiredTags,
    String? status,
    DateTime? createdAt,
    int? interestedUsersCount,
    List<int>? interestedUserIds,
    int? pendingUsersCount,
    int? approvedUsersCount,
    List<Map<String, dynamic>>? userStatuses,
    bool? currentUserInterested,
    String? currentUserStatus,
    double? compatibilityScore,
    double? explicitScore,
    double? implicitScore,
    double? baseCompatibilityScore,
    double? originalAIScore,
    bool? scoreValidated,
    bool? aiScoreUsed,
  }) {
    return DraftMatchModel(
      id: id ?? this.id,
      creatorUserId: creatorUserId ?? this.creatorUserId,
      creatorUserName: creatorUserName ?? this.creatorUserName,
      creatorAvatarUrl: creatorAvatarUrl ?? this.creatorAvatarUrl,
      sportType: sportType ?? this.sportType,
      locationDescription: locationDescription ?? this.locationDescription,
      estimatedStartTime: estimatedStartTime ?? this.estimatedStartTime,
      estimatedEndTime: estimatedEndTime ?? this.estimatedEndTime,
      slotsNeeded: slotsNeeded ?? this.slotsNeeded,
      skillLevel: skillLevel ?? this.skillLevel,
      requiredTags: requiredTags ?? this.requiredTags,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      interestedUsersCount: interestedUsersCount ?? this.interestedUsersCount,
      interestedUserIds: interestedUserIds ?? this.interestedUserIds,
      pendingUsersCount: pendingUsersCount ?? this.pendingUsersCount,
      approvedUsersCount: approvedUsersCount ?? this.approvedUsersCount,
      userStatuses: userStatuses ?? this.userStatuses,
      currentUserInterested: currentUserInterested ?? this.currentUserInterested,
      currentUserStatus: currentUserStatus ?? this.currentUserStatus,
      compatibilityScore: compatibilityScore ?? this.compatibilityScore,
      explicitScore: explicitScore ?? this.explicitScore,
      implicitScore: implicitScore ?? this.implicitScore,
      baseCompatibilityScore: baseCompatibilityScore ?? this.baseCompatibilityScore,
      originalAIScore: originalAIScore ?? this.originalAIScore,
      scoreValidated: scoreValidated ?? this.scoreValidated,
      aiScoreUsed: aiScoreUsed ?? this.aiScoreUsed,
    );
  }

  @override
  List<Object?> get props => [
    id,
    creatorUserId,
    creatorUserName,
    creatorAvatarUrl,
    sportType,
    locationDescription,
    estimatedStartTime,
    estimatedEndTime,
    slotsNeeded,
    skillLevel,
    requiredTags,
    status,
    createdAt,
    interestedUsersCount,
    interestedUserIds,
    pendingUsersCount,
    approvedUsersCount,
    userStatuses,
    currentUserInterested,
    currentUserStatus,
    compatibilityScore,
    explicitScore,
    implicitScore,
    baseCompatibilityScore,
    originalAIScore,
    scoreValidated,
    aiScoreUsed,
  ];
}

@JsonSerializable(explicitToJson: true)
class CreateDraftMatchRequest extends Equatable {
  final String sportType;
  final String locationDescription;
  final DateTime estimatedStartTime;
  final DateTime estimatedEndTime;
  final int slotsNeeded;
  final String skillLevel;
  final List<String> requiredTags;

  const CreateDraftMatchRequest({
    required this.sportType,
    required this.locationDescription,
    required this.estimatedStartTime,
    required this.estimatedEndTime,
    required this.slotsNeeded,
    required this.skillLevel,
    required this.requiredTags,
  });

  factory CreateDraftMatchRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateDraftMatchRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CreateDraftMatchRequestToJson(this);

  @override
  List<Object?> get props => [
    sportType,
    locationDescription,
    estimatedStartTime,
    estimatedEndTime,
    slotsNeeded,
    skillLevel,
    requiredTags,
  ];
}

@JsonSerializable(explicitToJson: true)
class DraftMatchResponse extends Equatable {
  final bool success;
  final String message;
  final DraftMatchModel? data;

  const DraftMatchResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DraftMatchResponse.fromJson(Map<String, dynamic> json) =>
      _$DraftMatchResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DraftMatchResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}

@JsonSerializable(explicitToJson: true)
class DraftMatchListResponse extends Equatable {
  final bool success;
  final String message;
  final List<DraftMatchModel> data;

  const DraftMatchListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DraftMatchListResponse.fromJson(Map<String, dynamic> json) =>
      _$DraftMatchListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DraftMatchListResponseToJson(this);

  @override
  List<Object?> get props => [success, message, data];
}
