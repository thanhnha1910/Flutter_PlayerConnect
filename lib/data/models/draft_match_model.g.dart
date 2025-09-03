// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DraftMatchModel _$DraftMatchModelFromJson(Map<String, dynamic> json) =>
    DraftMatchModel(
      id: (json['id'] as num).toInt(),
      creatorUserId: (json['creatorUserId'] as num).toInt(),
      creatorUserName: json['creatorUserName'] as String,
      creatorAvatarUrl: json['creatorAvatarUrl'] as String?,
      sportType: json['sportType'] as String,
      locationDescription: json['locationDescription'] as String,
      estimatedStartTime: DateTime.parse(json['estimatedStartTime'] as String),
      estimatedEndTime: DateTime.parse(json['estimatedEndTime'] as String),
      slotsNeeded: (json['slotsNeeded'] as num).toInt(),
      skillLevel: json['skillLevel'] as String,
      requiredTags: (json['requiredTags'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      interestedUsersCount: (json['interestedUsersCount'] as num).toInt(),
      interestedUserIds: (json['interestedUserIds'] as List<dynamic>)
          .map((e) => (e as num).toInt())
          .toList(),
      pendingUsersCount: (json['pendingUsersCount'] as num).toInt(),
      approvedUsersCount: (json['approvedUsersCount'] as num).toInt(),
      userStatuses: (json['userStatuses'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      currentUserInterested: json['currentUserInterested'] as bool?,
      currentUserStatus: json['currentUserStatus'] as String?,
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble(),
      explicitScore: (json['explicitScore'] as num?)?.toDouble(),
      implicitScore: (json['implicitScore'] as num?)?.toDouble(),
      baseCompatibilityScore: (json['baseCompatibilityScore'] as num?)
          ?.toDouble(),
      originalAIScore: (json['originalAIScore'] as num?)?.toDouble(),
      scoreValidated: json['scoreValidated'] as bool?,
      aiScoreUsed: json['aiScoreUsed'] as bool?,
    );

Map<String, dynamic> _$DraftMatchModelToJson(DraftMatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'creatorUserId': instance.creatorUserId,
      'creatorUserName': instance.creatorUserName,
      'creatorAvatarUrl': instance.creatorAvatarUrl,
      'sportType': instance.sportType,
      'locationDescription': instance.locationDescription,
      'estimatedStartTime': instance.estimatedStartTime.toIso8601String(),
      'estimatedEndTime': instance.estimatedEndTime.toIso8601String(),
      'slotsNeeded': instance.slotsNeeded,
      'skillLevel': instance.skillLevel,
      'requiredTags': instance.requiredTags,
      'status': instance.status,
      'createdAt': instance.createdAt.toIso8601String(),
      'interestedUsersCount': instance.interestedUsersCount,
      'interestedUserIds': instance.interestedUserIds,
      'pendingUsersCount': instance.pendingUsersCount,
      'approvedUsersCount': instance.approvedUsersCount,
      'userStatuses': instance.userStatuses,
      'currentUserInterested': instance.currentUserInterested,
      'currentUserStatus': instance.currentUserStatus,
      'compatibilityScore': instance.compatibilityScore,
      'explicitScore': instance.explicitScore,
      'implicitScore': instance.implicitScore,
      'baseCompatibilityScore': instance.baseCompatibilityScore,
      'originalAIScore': instance.originalAIScore,
      'scoreValidated': instance.scoreValidated,
      'aiScoreUsed': instance.aiScoreUsed,
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
