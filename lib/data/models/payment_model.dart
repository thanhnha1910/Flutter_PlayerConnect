import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/payment.dart';

part 'payment_model.g.dart'; // 🔑 liên kết tới file generate

@JsonSerializable()
class PaymentModel {
  final int paymentId;
  final int total;
  final String method;
  final String status;
  final int payableId;
  final String payableType;

  PaymentModel({
    required this.paymentId,
    required this.total,
    required this.method,
    required this.status,
    required this.payableId,
    required this.payableType,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);

  Payment toEntity() => Payment(
    id: paymentId,
    total: total,
    method: method,
    status: status,
    payableId: payableId,
    payableType: payableType,
  );
}