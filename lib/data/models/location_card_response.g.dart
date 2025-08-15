// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_card_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationCardResponse _$LocationCardResponseFromJson(
  Map<String, dynamic> json,
) => LocationCardResponse(
  locationId: LocationCardResponse._parseLocationId(json['locationId']),
  locationName: json['locationName'] as String,
  slug: json['slug'] as String,
  address: json['address'] as String,
  mainImageUrl: json['mainImageUrl'] as String?,
  fieldCount: (json['fieldCount'] as num).toInt(),
  averageRating: LocationCardResponse._parseNullableDouble(
    json['averageRating'],
  ),
  startingPrice: LocationCardResponse._parseNullableDouble(
    json['startingPrice'],
  ),
  bookingCount: (json['bookingCount'] as num).toInt(),
  distance: (json['distance'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationCardResponseToJson(
  LocationCardResponse instance,
) => <String, dynamic>{
  'locationId': instance.locationId,
  'locationName': instance.locationName,
  'slug': instance.slug,
  'address': instance.address,
  'mainImageUrl': instance.mainImageUrl,
  'fieldCount': instance.fieldCount,
  'averageRating': instance.averageRating,
  'startingPrice': instance.startingPrice,
  'bookingCount': instance.bookingCount,
  'distance': instance.distance,
};
