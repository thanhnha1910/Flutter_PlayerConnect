// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingModel _$BookingModelFromJson(Map<String, dynamic> json) => BookingModel(
  id: json['id'] as String?,
  fieldId: (json['fieldId'] as num?)?.toInt(),
  startTime: json['fromTime'] == null
      ? null
      : DateTime.parse(json['fromTime'] as String),
  endTime: json['toTime'] == null
      ? null
      : DateTime.parse(json['toTime'] as String),
  status: json['status'] as String?,
  customerName: json['customerName'] as String?,
  customerPhone: json['customerPhone'] as String?,
  basePrice: json['basePrice'] as num?,
  discountPercent: json['discountPercent'] as num?,
  discountAmount: json['discountAmount'] as num?,
  totalPrice: json['totalPrice'] as num?,
  booked: json['booked'] as bool?,
);

Map<String, dynamic> _$BookingModelToJson(BookingModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fieldId': instance.fieldId,
      'fromTime': instance.startTime?.toIso8601String(),
      'toTime': instance.endTime?.toIso8601String(),
      'status': instance.status,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'basePrice': instance.basePrice,
      'discountPercent': instance.discountPercent,
      'discountAmount': instance.discountAmount,
      'totalPrice': instance.totalPrice,
      'booked': instance.booked,
    };
