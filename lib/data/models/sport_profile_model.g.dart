// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportProfileModel _$SportProfileModelFromJson(Map<String, dynamic> json) =>
    SportProfileModel(
      id: (json['id'] as num?)?.toInt(),
      sportId: (json['sportId'] as num).toInt(),
      sportName: json['sportName'] as String,
      sportIcon: json['sportIcon'] as String?,
      skill: (json['skill'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportProfileModelToJson(SportProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sportId': instance.sportId,
      'sportName': instance.sportName,
      'sportIcon': instance.sportIcon,
      'skill': instance.skill,
      'tags': instance.tags.map((e) => e.toJson()).toList(),
    };

SportProfileRequest _$SportProfileRequestFromJson(Map<String, dynamic> json) =>
    SportProfileRequest(
      sportId: (json['sportId'] as num?)?.toInt(),
      sportName: json['sportName'] as String,
      sportIcon: json['sportIcon'] as String?,
      skill: (json['skill'] as num).toInt(),
      tags: (json['tags'] as List<dynamic>)
          .map((e) => TagRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SportProfileRequestToJson(
  SportProfileRequest instance,
) => <String, dynamic>{
  'sportId': instance.sportId,
  'sportName': instance.sportName,
  'sportIcon': instance.sportIcon,
  'skill': instance.skill,
  'tags': instance.tags.map((e) => e.toJson()).toList(),
};
