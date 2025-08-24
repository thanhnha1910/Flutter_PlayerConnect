// data/models/payment_approval_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/paymentapproval.dart';

part 'payment_approval_model.g.dart';

@JsonSerializable()
class PaymentApprovalModel {
  @JsonKey(name: 'approval_url')
  final String approvalUrl;

  @JsonKey(name: 'payment_id')
  final int paymentId;

  PaymentApprovalModel({
    required this.approvalUrl,
    required this.paymentId,
  });

  factory PaymentApprovalModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentApprovalModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentApprovalModelToJson(this);

  PaymentApproval toEntity() {
    return PaymentApproval(
      approvalUrl: approvalUrl,
      paymentId: paymentId,
    );
  }
}
