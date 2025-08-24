// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_approval_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentApprovalModel _$PaymentApprovalModelFromJson(
  Map<String, dynamic> json,
) => PaymentApprovalModel(
  approvalUrl: json['approval_url'] as String,
  paymentId: (json['payment_id'] as num).toInt(),
);

Map<String, dynamic> _$PaymentApprovalModelToJson(
  PaymentApprovalModel instance,
) => <String, dynamic>{
  'approval_url': instance.approvalUrl,
  'payment_id': instance.paymentId,
};
