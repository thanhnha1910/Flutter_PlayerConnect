// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_history_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingHistoryModel _$BookingHistoryModelFromJson(Map<String, dynamic> json) =>
    BookingHistoryModel(
      id: (json['bookingId'] as num).toInt(),
      fieldName: json['fieldName'] as String,
      locationName: json['fieldAddress'] as String,
      sportType: json['sportType'] as String?,
      bookingDate: DateTime.parse(json['startTime'] as String),
      timeSlot: json['timeSlot'] as String?,
      price: (json['totalPrice'] as num?)?.toDouble(),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['endTime'] == null
          ? null
          : DateTime.parse(json['endTime'] as String),
    );

Map<String, dynamic> _$BookingHistoryModelToJson(
  BookingHistoryModel instance,
) => <String, dynamic>{
  'bookingId': instance.id,
  'fieldName': instance.fieldName,
  'fieldAddress': instance.locationName,
  'sportType': instance.sportType,
  'startTime': instance.bookingDate.toIso8601String(),
  'timeSlot': instance.timeSlot,
  'totalPrice': instance.price,
  'status': instance.status,
  'notes': instance.notes,
  'createdAt': instance.createdAt?.toIso8601String(),
  'endTime': instance.updatedAt?.toIso8601String(),
};
