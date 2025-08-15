// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: (json['id'] as num).toInt(),
  fieldId: (json['fieldId'] as num).toInt(),
  fieldName: json['fieldName'] as String,
  startTime: DateTime.parse(json['startTime'] as String),
  endTime: DateTime.parse(json['endTime'] as String),
  totalPrice: (json['totalPrice'] as num).toDouble(),
  status: json['status'] as String,
  notes: json['notes'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fieldId': instance.fieldId,
      'fieldName': instance.fieldName,
      'startTime': instance.startTime.toIso8601String(),
      'endTime': instance.endTime.toIso8601String(),
      'totalPrice': instance.totalPrice,
      'status': instance.status,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
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
