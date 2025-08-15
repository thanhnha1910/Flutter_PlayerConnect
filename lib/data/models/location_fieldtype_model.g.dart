// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_fieldtype_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationFieldTypeModel _$LocationFieldTypeModelFromJson(
  Map<String, dynamic> json,
) => LocationFieldTypeModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  teamCapacity: (json['teamCapacity'] as num).toInt(),
  maxCapacity: (json['maxCapacity'] as num).toInt(),
  hourlyRate: (json['hourlyRate'] as num).toInt(),
  description: json['description'] as String?,
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => LocationFieldModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationFieldTypeModelToJson(
  LocationFieldTypeModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'teamCapacity': instance.teamCapacity,
  'maxCapacity': instance.maxCapacity,
  'hourlyRate': instance.hourlyRate,
  'description': instance.description,
  'fields': instance.fields?.map((e) => e.toJson()).toList(),
};
