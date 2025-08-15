// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationDetailsModel _$LocationDetailsModelFromJson(
  Map<String, dynamic> json,
) => LocationDetailsModel(
  name: json['name'] as String,
  address: json['address'] as String,
  reviews: (json['reviews'] as List<dynamic>?)
      ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationDetailsModelToJson(
  LocationDetailsModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'address': instance.address,
  'reviews': instance.reviews?.map((e) => e.toJson()).toList(),
};
