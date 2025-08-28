// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FieldTypeModel _$FieldTypeModelFromJson(Map<String, dynamic> json) =>
    FieldTypeModel(
      typeId: (json['typeId'] as num?)?.toInt(),
      name: json['name'] as String?,
      teamCapacity: (json['teamCapacity'] as num?)?.toInt(),
      maxCapacity: (json['maxCapacity'] as num?)?.toInt(),
      hourlyRate: (json['hourlyRate'] as num?)?.toInt(),
      description: json['description'] as String?,
      locationId: (json['locationId'] as num?)?.toInt(),
      locationName: json['locationName'] as String?,
      fields: (json['fields'] as List<dynamic>?)
          ?.map((e) => FieldModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FieldTypeModelToJson(FieldTypeModel instance) =>
    <String, dynamic>{
      'typeId': instance.typeId,
      'name': instance.name,
      'teamCapacity': instance.teamCapacity,
      'maxCapacity': instance.maxCapacity,
      'hourlyRate': instance.hourlyRate,
      'description': instance.description,
      'locationId': instance.locationId,
      'locationName': instance.locationName,
      'fields': instance.fields?.map((e) => e.toJson()).toList(),
    };

FieldModel _$FieldModelFromJson(Map<String, dynamic> json) => FieldModel(
  id: (json['id'] as num?)?.toInt(),
  name: json['name'] as String?,
  description: json['description'] as String?,
  hourlyRate: (json['hourlyRate'] as num?)?.toInt(),
  thumbnailUrl: json['thumbnailUrl'] as String?,
  imageGallery: json['imageGallery'] as String?,
);

Map<String, dynamic> _$FieldModelToJson(FieldModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hourlyRate': instance.hourlyRate,
      'thumbnailUrl': instance.thumbnailUrl,
      'imageGallery': instance.imageGallery,
    };

LocationDetailsModel _$LocationDetailsModelFromJson(
  Map<String, dynamic> json,
) => LocationDetailsModel(
  name: json['name'] as String,
  address: json['address'] as String,
  description: json['description'] as String?,
  fieldTypes: (json['fieldTypes'] as List<dynamic>?)
      ?.map((e) => FieldTypeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  reviews: (json['reviews'] as List<dynamic>?)
      ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationDetailsModelToJson(
  LocationDetailsModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'description': instance.description,
  'fieldTypes': instance.fieldTypes?.map((e) => e.toJson()).toList(),
  'reviews': instance.reviews?.map((e) => e.toJson()).toList(),
};
