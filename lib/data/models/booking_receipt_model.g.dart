// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookingReceiptModel _$BookingReceiptModelFromJson(Map<String, dynamic> json) =>
    BookingReceiptModel(
      id: (json['bookingId'] as num).toInt(),
      startTime: DateTime.parse(json['fromTime'] as String),
      endTime: DateTime.parse(json['toTime'] as String),
      slots: (json['slots'] as num?)?.toInt(),
      status: json['status'] as String,
      paymentToken: json['paymentToken'] as String?,
      userId: (json['userId'] as num?)?.toInt(),
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      fieldId: (json['fieldId'] as num?)?.toInt(),
      fieldName: json['fieldName'] as String?,
      fieldDescription: json['fieldDescription'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      locationAddress: json['locationAddress'] as String?,
      fieldTypeName: json['fieldTypeName'] as String?,
      fieldCategoryName: json['fieldCategoryName'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      durationHours: (json['durationHours'] as num?)?.toInt(),
      openMatch: json['openMatch'] == null
          ? null
          : OpenMatchSummary.fromJson(
              json['openMatch'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$BookingReceiptModelToJson(
  BookingReceiptModel instance,
) => <String, dynamic>{
  'bookingId': instance.id,
  'fromTime': instance.startTime.toIso8601String(),
  'toTime': instance.endTime.toIso8601String(),
  'slots': instance.slots,
  'status': instance.status,
  'paymentToken': instance.paymentToken,
  'userId': instance.userId,
  'customerName': instance.customerName,
  'customerEmail': instance.customerEmail,
  'customerPhone': instance.customerPhone,
  'fieldId': instance.fieldId,
  'fieldName': instance.fieldName,
  'fieldDescription': instance.fieldDescription,
  'hourlyRate': instance.hourlyRate,
  'locationName': instance.locationName,
  'locationAddress': instance.locationAddress,
  'fieldTypeName': instance.fieldTypeName,
  'fieldCategoryName': instance.fieldCategoryName,
  'totalPrice': instance.totalPrice,
  'durationHours': instance.durationHours,
  'openMatch': instance.openMatch?.toJson(),
};

OpenMatchSummary _$OpenMatchSummaryFromJson(Map<String, dynamic> json) =>
    OpenMatchSummary(
      id: (json['id'] as num).toInt(),
      sportType: json['sportType'] as String,
      slotsNeeded: (json['slotsNeeded'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$OpenMatchSummaryToJson(OpenMatchSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sportType': instance.sportType,
      'slotsNeeded': instance.slotsNeeded,
      'status': instance.status,
    };

BatchBookingReceiptModel _$BatchBookingReceiptModelFromJson(
  Map<String, dynamic> json,
) => BatchBookingReceiptModel(
  bookings: (json['bookings'] as List<dynamic>)
      .map((e) => BookingReceiptModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalBookings: (json['totalBookings'] as num).toInt(),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  isBatch: json['isBatch'] as bool,
  message: json['message'] as String,
);

Map<String, dynamic> _$BatchBookingReceiptModelToJson(
  BatchBookingReceiptModel instance,
) => <String, dynamic>{
  'bookings': instance.bookings.map((e) => e.toJson()).toList(),
  'totalBookings': instance.totalBookings,
  'totalAmount': instance.totalAmount,
  'isBatch': instance.isBatch,
  'message': instance.message,
};
