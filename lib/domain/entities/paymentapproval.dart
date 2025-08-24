// domain/entities/payment_approval.dart
import 'package:equatable/equatable.dart';

class PaymentApproval extends Equatable {
  final String approvalUrl;
  final int paymentId;

  const PaymentApproval({
    required this.approvalUrl,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [approvalUrl, paymentId];
}
