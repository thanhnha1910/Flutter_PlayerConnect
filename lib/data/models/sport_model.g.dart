// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sport_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SportModel _$SportModelFromJson(Map<String, dynamic> json) => SportModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  sportCode: json['sportCode'] as String,
  icon: json['icon'] as String?,
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$SportModelToJson(SportModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sportCode': instance.sportCode,
      'icon': instance.icon,
      'isActive': instance.isActive,
    };
