// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'open_match_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenMatchModel _$OpenMatchModelFromJson(Map<String, dynamic> json) =>
    OpenMatchModel(
      id: (json['id'] as num).toInt(),
      fieldName: json['fieldName'] as String,
      fieldAddress: json['fieldAddress'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      currentPlayers: (json['currentPlayers'] as num).toInt(),
      maxPlayers: (json['maxPlayers'] as num).toInt(),
      pricePerPerson: (json['pricePerPerson'] as num).toDouble(),
      description: json['description'] as String?,
      fieldImageUrl: json['fieldImageUrl'] as String?,
      aiCompatibilityScore: (json['aiCompatibilityScore'] as num?)?.toDouble(),
      organizerName: json['organizerName'] as String,
      organizerAvatar: json['organizerAvatar'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      skillLevel: json['skillLevel'] as String? ?? 'intermediate',
      gameType: json['gameType'] as String? ?? 'football',
    );

Map<String, dynamic> _$OpenMatchModelToJson(OpenMatchModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fieldName': instance.fieldName,
      'fieldAddress': instance.fieldAddress,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'currentPlayers': instance.currentPlayers,
      'maxPlayers': instance.maxPlayers,
      'pricePerPerson': instance.pricePerPerson,
      'description': instance.description,
      'fieldImageUrl': instance.fieldImageUrl,
      'aiCompatibilityScore': instance.aiCompatibilityScore,
      'organizerName': instance.organizerName,
      'organizerAvatar': instance.organizerAvatar,
      'tags': instance.tags,
      'skillLevel': instance.skillLevel,
      'gameType': instance.gameType,
    };
