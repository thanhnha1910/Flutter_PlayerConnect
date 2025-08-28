// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdditionalPlayerModel _$AdditionalPlayerModelFromJson(
  Map<String, dynamic> json,
) => AdditionalPlayerModel(
  userId: (json['userId'] as num).toInt(),
  position: json['position'] as String?,
);

Map<String, dynamic> _$AdditionalPlayerModelToJson(
  AdditionalPlayerModel instance,
) => <String, dynamic>{
  'userId': instance.userId,
  'position': instance.position,
};

BookingRequestModel _$BookingRequestModelFromJson(Map<String, dynamic> json) =>
    BookingRequestModel(
      fieldId: (json['fieldId'] as num).toInt(),
      fromTime: DateTime.parse(json['fromTime'] as String),
      toTime: DateTime.parse(json['toTime'] as String),
      slots: (json['slots'] as num?)?.toInt(),
      findTeammates: json['findTeammates'] as bool?,
      additionalPlayers: (json['additionalPlayers'] as List<dynamic>?)
          ?.map(
            (e) => AdditionalPlayerModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$BookingRequestModelToJson(
  BookingRequestModel instance,
) => <String, dynamic>{
  'fieldId': instance.fieldId,
  'fromTime': instance.fromTime.toIso8601String(),
  'toTime': instance.toTime.toIso8601String(),
  'slots': instance.slots,
  'findTeammates': instance.findTeammates,
  'additionalPlayers': instance.additionalPlayers
      ?.map((e) => e.toJson())
      .toList(),
};

BookingResponseModel _$BookingResponseModelFromJson(
  Map<String, dynamic> json,
) => BookingResponseModel(
  bookingId: (json['bookingId'] as num).toInt(),
  status: json['status'] as String?,
  message: json['message'] as String?,
  paymentUrl: json['payUrl'] as String?,
  paymentId: json['paymentId'] as String?,
  booking: json['booking'] == null
      ? null
      : BookingModel.fromJson(json['booking'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BookingResponseModelToJson(
  BookingResponseModel instance,
) => <String, dynamic>{
  'bookingId': instance.bookingId,
  'status': instance.status,
  'message': instance.message,
  'payUrl': instance.paymentUrl,
  'paymentId': instance.paymentId,
  'booking': instance.booking?.toJson(),
};

PayPalPaymentModel _$PayPalPaymentModelFromJson(Map<String, dynamic> json) =>
    PayPalPaymentModel(
      paymentId: json['paymentId'] as String,
      payerId: json['payerId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PayPalPaymentModelToJson(PayPalPaymentModel instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'payerId': instance.payerId,
      'status': instance.status,
      'amount': instance.amount,
      'currency': instance.currency,
      'createdAt': instance.createdAt.toIso8601String(),
    };
