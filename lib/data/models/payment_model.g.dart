// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  paymentId: (json['paymentId'] as num).toInt(),
  total: (json['total'] as num).toInt(),
  method: json['method'] as String,
  status: json['status'] as String,
  payableId: (json['payableId'] as num).toInt(),
  payableType: json['payableType'] as String,
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'paymentId': instance.paymentId,
      'total': instance.total,
      'method': instance.method,
      'status': instance.status,
      'payableId': instance.payableId,
      'payableType': instance.payableType,
    };
