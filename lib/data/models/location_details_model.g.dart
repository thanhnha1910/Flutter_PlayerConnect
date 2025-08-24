// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_details_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationDetailsModel _$LocationDetailsModelFromJson(
  Map<String, dynamic> json,
) => LocationDetailsModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  fields: (json['fields'] as List<dynamic>?)
      ?.map((e) => FieldModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  reviews: (json['reviews'] as List<dynamic>?)
      ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LocationDetailsModelToJson(
  LocationDetailsModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'fields': instance.fields?.map((e) => e.toJson()).toList(),
  'reviews': instance.reviews?.map((e) => e.toJson()).toList(),
};

FieldModel _$FieldModelFromJson(Map<String, dynamic> json) => FieldModel(
  id: (json['id'] as num).toInt(),
  name: json['field_name'] as String,
  pricePerHour: (json['price_per_hour'] as num).toDouble(),
);

Map<String, dynamic> _$FieldModelToJson(FieldModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'field_name': instance.name,
      'price_per_hour': instance.pricePerHour,
    };

ReviewModel _$ReviewModelFromJson(Map<String, dynamic> json) => ReviewModel(
  rating: (json['rating'] as num).toInt(),
  comment: json['comment'] as String,
);

Map<String, dynamic> _$ReviewModelToJson(ReviewModel instance) =>
    <String, dynamic>{'rating': instance.rating, 'comment': instance.comment};
