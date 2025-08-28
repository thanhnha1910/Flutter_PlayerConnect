// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TeamModel _$TeamModelFromJson(Map<String, dynamic> json) => TeamModel(
  id: (json['teamId'] as num?)?.toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  description: json['description'] as String?,
  logo: json['logo'] as String?,
  captainId: (json['captainId'] as num?)?.toInt(),
  captain: json['captain'] == null
      ? null
      : UserModel.fromJson(json['captain'] as Map<String, dynamic>),
  members: (json['members'] as List<dynamic>?)
      ?.map((e) => UserModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TeamModelToJson(TeamModel instance) => <String, dynamic>{
  'teamId': instance.id,
  'name': instance.name,
  'code': instance.code,
  'description': instance.description,
  'logo': instance.logo,
  'captainId': instance.captainId,
  'captain': instance.captain,
  'members': instance.members,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
