// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenMatchModel _$OpenMatchModelFromJson(Map<String, dynamic> json) =>
    OpenMatchModel(
      id: (json['id'] as num).toInt(),
      fieldName: json['fieldName'] as String?,
      locationName: json['locationName'] as String?,
      fieldAddress: json['fieldAddress'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      currentPlayers: (json['currentPlayers'] as num?)?.toInt(),
      currentParticipants: (json['currentParticipants'] as num?)?.toInt(),
      maxPlayers: (json['maxPlayers'] as num?)?.toInt(),
      slotsNeeded: (json['slotsNeeded'] as num?)?.toInt(),
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      description: json['description'] as String?,
      fieldImageUrl: json['fieldImageUrl'] as String?,
      aiCompatibilityScore: (json['aiCompatibilityScore'] as num?)?.toDouble(),
      compatibilityScore: (json['compatibilityScore'] as num?)?.toDouble(),
      organizerName: json['organizerName'] as String?,
      creatorUserName: json['creatorUserName'] as String?,
      organizerAvatar: json['organizerAvatar'] as String?,
      creatorAvatarUrl: json['creatorAvatarUrl'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      requiredTags: (json['requiredTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      skillLevel: json['skillLevel'] as String? ?? 'intermediate',
      gameType: json['gameType'] as String? ?? 'football',
      currentUserJoinStatus:
          $enumDecodeNullable(
            _$JoinStatusEnumMap,
            json['currentUserJoinStatus'],
          ) ??
          JoinStatus.NOT_JOINED,
      creatorUserId: json['creatorUserId'] as String?,
      isCreator: json['isCreator'] as bool? ?? false,
    );

Map<String, dynamic> _$OpenMatchModelToJson(
  OpenMatchModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'fieldName': instance.fieldName,
  'locationName': instance.locationName,
  'fieldAddress': instance.fieldAddress,
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'currentPlayers': instance.currentPlayers,
  'currentParticipants': instance.currentParticipants,
  'maxPlayers': instance.maxPlayers,
  'slotsNeeded': instance.slotsNeeded,
  'pricePerPerson': instance.pricePerPerson,
  'description': instance.description,
  'fieldImageUrl': instance.fieldImageUrl,
  'aiCompatibilityScore': instance.aiCompatibilityScore,
  'compatibilityScore': instance.compatibilityScore,
  'organizerName': instance.organizerName,
  'creatorUserName': instance.creatorUserName,
  'organizerAvatar': instance.organizerAvatar,
  'creatorAvatarUrl': instance.creatorAvatarUrl,
  'tags': instance.tags,
  'requiredTags': instance.requiredTags,
  'skillLevel': instance.skillLevel,
  'gameType': instance.gameType,
  'currentUserJoinStatus': _$JoinStatusEnumMap[instance.currentUserJoinStatus]!,
  'creatorUserId': instance.creatorUserId,
  'isCreator': instance.isCreator,
};

const _$JoinStatusEnumMap = {
  JoinStatus.NOT_JOINED: 'NOT_JOINED',
  JoinStatus.REQUEST_PENDING: 'REQUEST_PENDING',
  JoinStatus.JOINED: 'JOINED',
};
