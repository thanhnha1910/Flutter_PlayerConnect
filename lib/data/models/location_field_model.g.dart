// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_field_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationFieldModel _$LocationFieldModelFromJson(Map<String, dynamic> json) =>
    LocationFieldModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      hourlyRate: (json['hourlyRate'] as num).toInt(),
      bookings: (json['bookings'] as List<dynamic>?)
          ?.map((e) => BookingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationFieldModelToJson(LocationFieldModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'hourlyRate': instance.hourlyRate,
      'bookings': instance.bookings?.map((e) => e.toJson()).toList(),
    };
