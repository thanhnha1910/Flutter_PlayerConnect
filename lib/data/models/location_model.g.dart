// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: (json['reviewCount'] as num?)?.toInt(),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      pricePerHour: (json['pricePerHour'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      distance: (json['distance'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'description': instance.description,
      'imageUrl': instance.imageUrl,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'amenities': instance.amenities,
      'pricePerHour': instance.pricePerHour,
      'isActive': instance.isActive,
      'distance': instance.distance,
    };
