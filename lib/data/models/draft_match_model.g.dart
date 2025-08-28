// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftMatchModel _$DraftMatchModelFromJson(Map<String, dynamic> json) =>
    DraftMatchModel(
      id: (json['id'] as num).toInt(),
      sportType: json['sportType'] as String,
      locationDescription: json['locationDescription'] as String,
      estimatedStartTime: DateTime.parse(json['estimatedStartTime'] as String),
      estimatedEndTime: DateTime.parse(json['estimatedEndTime'] as String),
      slotsNeeded: (json['slotsNeeded'] as num).toInt(),
      skillLevel: json['skillLevel'] as String,
      requiredTags: (json['requiredTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      creator: UserModel.fromJson(json['creator'] as Map<String, dynamic>),
      interestedUsers: (json['interestedUsers'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      approvedUsers: (json['approvedUsers'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      aiCompatibilityScore: (json['aiCompatibilityScore'] as num?)?.toDouble(),
      hasUserExpressedInterest: json['hasUserExpressedInterest'] as bool?,
      isUserApproved: json['isUserApproved'] as bool?,
      isCreatedByUser: json['isCreatedByUser'] as bool?,
    );

Map<String, dynamic> _$DraftMatchModelToJson(
  DraftMatchModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'sportType': instance.sportType,
  'locationDescription': instance.locationDescription,
  'estimatedStartTime': instance.estimatedStartTime.toIso8601String(),
  'estimatedEndTime': instance.estimatedEndTime.toIso8601String(),
  'slotsNeeded': instance.slotsNeeded,
  'skillLevel': instance.skillLevel,
  'requiredTags': instance.requiredTags,
  'creator': instance.creator.toJson(),
  'interestedUsers': instance.interestedUsers.map((e) => e.toJson()).toList(),
  'approvedUsers': instance.approvedUsers.map((e) => e.toJson()).toList(),
  'status': instance.status,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'aiCompatibilityScore': instance.aiCompatibilityScore,
  'hasUserExpressedInterest': instance.hasUserExpressedInterest,
  'isUserApproved': instance.isUserApproved,
  'isCreatedByUser': instance.isCreatedByUser,
};

CreateDraftMatchRequest _$CreateDraftMatchRequestFromJson(
  Map<String, dynamic> json,
) => CreateDraftMatchRequest(
  sportType: json['sportType'] as String,
  locationDescription: json['locationDescription'] as String,
  estimatedStartTime: DateTime.parse(json['estimatedStartTime'] as String),
  estimatedEndTime: DateTime.parse(json['estimatedEndTime'] as String),
  slotsNeeded: (json['slotsNeeded'] as num).toInt(),
  skillLevel: json['skillLevel'] as String,
  requiredTags: (json['requiredTags'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CreateDraftMatchRequestToJson(
  CreateDraftMatchRequest instance,
) => <String, dynamic>{
  'sportType': instance.sportType,
  'locationDescription': instance.locationDescription,
  'estimatedStartTime': instance.estimatedStartTime.toIso8601String(),
  'estimatedEndTime': instance.estimatedEndTime.toIso8601String(),
  'slotsNeeded': instance.slotsNeeded,
  'skillLevel': instance.skillLevel,
  'requiredTags': instance.requiredTags,
};

DraftMatchResponse _$DraftMatchResponseFromJson(Map<String, dynamic> json) =>
    DraftMatchResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] == null
          ? null
          : DraftMatchModel.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DraftMatchResponseToJson(DraftMatchResponse instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };

DraftMatchListResponse _$DraftMatchListResponseFromJson(
  Map<String, dynamic> json,
) => DraftMatchListResponse(
  success: json['success'] as bool,
  message: json['message'] as String,
  data: (json['data'] as List<dynamic>)
      .map((e) => DraftMatchModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$DraftMatchListResponseToJson(
  DraftMatchListResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
  'data': instance.data.map((e) => e.toJson()).toList(),
};
