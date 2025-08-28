import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'user_model.dart';

part 'draft_match_model.g.dart';

@JsonSerializable(explicitToJson: true)
class DraftMatchModel extends Equatable {
  final int id;
  final String sportType;
  final String locationDescription;
  final DateTime estimatedStartTime;
  final DateTime estimatedEndTime;
  final int slotsNeeded;
  final String skillLevel;
  final List<String> requiredTags;
  final UserModel creator;
  final List<UserModel> interestedUsers;
  final List<UserModel> approvedUsers;
  final String status; // 'ACTIVE', 'COMPLETED', 'CANCELLED'
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? aiCompatibilityScore;
  final bool? hasUserExpressedInterest;
  final bool? isUserApproved;
  final bool? isCreatedByUser;

  const DraftMatchModel({
    required this.id,
    required this.sportType,
    required this.locationDescription,
    required this.estimatedStartTime,
    required this.estimatedEndTime,
    required this.slotsNeeded,
    required this.skillLevel,
    required this.requiredTags,
    required this.creator,
    required this.interestedUsers,
    required this.approvedUsers,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.aiCompatibilityScore,
    this.hasUserExpressedInterest,
    this.isUserApproved,
    this.isCreatedByUser,
  });

  factory DraftMatchModel.fromJson(Map<String, dynamic> json) =>
      _$DraftMatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$DraftMatchModelToJson(this);

  // Helper getters
  int get approvedSlotsCount => approvedUsers.length;
  int get remainingSlotsCount => slotsNeeded - approvedSlotsCount;
  bool get isFull => approvedSlotsCount >= slotsNeeded;
  bool get isActive => status == 'ACTIVE';
  
  // Duration helper
  Duration get estimatedDuration => estimatedEndTime.difference(estimatedStartTime);
  
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

  @override
  List<Object?> get props => [
        id,
        sportType,
        locationDescription,
        estimatedStartTime,
        estimatedEndTime,
        slotsNeeded,
        skillLevel,
        requiredTags,
        creator,
        interestedUsers,
        approvedUsers,
        status,
        createdAt,
        updatedAt,
        aiCompatibilityScore,
        hasUserExpressedInterest,
        isUserApproved,
        isCreatedByUser,
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