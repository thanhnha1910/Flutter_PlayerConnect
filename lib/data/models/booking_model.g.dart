// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: (json['booking_id'] as num).toInt(),
  fieldId: (json['field_id'] as num).toInt(),
  fieldName: json['fieldName'] as String,
  startTime: DateTime.parse(json['start_time'] as String),
  endTime: DateTime.parse(json['end_time'] as String),
  totalPrice: (json['total_price'] as num).toDouble(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'booking_id': instance.id,
      'field_id': instance.fieldId,
      'fieldName': instance.fieldName,
      'start_time': instance.startTime.toIso8601String(),
      'end_time': instance.endTime.toIso8601String(),
      'total_price': instance.totalPrice,
      'status': instance.status,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

TimeSlot _$TimeSlotFromJson(Map<String, dynamic> json) => TimeSlot(
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  isAvailable: json['isAvailable'] as bool,
  pricePerHour: (json['pricePerHour'] as num).toDouble(),
  bookedBy: json['bookedBy'] as String?,
);

Map<String, dynamic> _$TimeSlotToJson(TimeSlot instance) => <String, dynamic>{
  'startTime': instance.startTime.toIso8601String(),
  'endTime': instance.endTime.toIso8601String(),
  'isAvailable': instance.isAvailable,
  'pricePerHour': instance.pricePerHour,
  'bookedBy': instance.bookedBy,
};
