// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_map_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationMapModel _$LocationMapModelFromJson(Map<String, dynamic> json) =>
    LocationMapModel(
      locationId: LocationMapModel._parseLocationId(json['locationId']),
      name: json['name'] as String,
      slug: json['slug'] as String,
      address: json['address'] as String,
      latitude: LocationMapModel._parseDouble(json['latitude']),
      longitude: LocationMapModel._parseDouble(json['longitude']),
      fieldCount: (json['fieldCount'] as num).toInt(),
      averageRating: LocationMapModel._parseNullableDouble(
        json['averageRating'],
      ),
      thumbnailImageUrl: json['thumbnailImageUrl'] as String?,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocationMapModelToJson(LocationMapModel instance) =>
    <String, dynamic>{
      'locationId': instance.locationId,
      'name': instance.name,
      'slug': instance.slug,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'fieldCount': instance.fieldCount,
      'averageRating': instance.averageRating,
      'thumbnailImageUrl': instance.thumbnailImageUrl,
      'distance': instance.distance,
    };
