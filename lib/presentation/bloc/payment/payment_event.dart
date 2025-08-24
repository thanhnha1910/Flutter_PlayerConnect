part of 'payment_bloc.dart';

abstract class PaymentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitiatePaymentEvent extends PaymentEvent {
  final int payableId;
  final String payableType;
  final int amount;

  InitiatePaymentEvent({
    required this.payableId,
    required this.payableType,
    required this.amount,
  });

  @override
  List<Object?> get props => [payableId, payableType, amount];
}

class GetPaymentStatusEvent extends PaymentEvent {
  final int paymentId;

  GetPaymentStatusEvent(this.paymentId);

  @override
  List<Object?> get props => [paymentId];
}

class ResetPaymentEvent extends PaymentEvent {}

class ProcessPaymentCallbackEvent extends PaymentEvent {
  final String? paymentId;
  final String? payerId;
  final String? token;
  final bool isSuccess;

  ProcessPaymentCallbackEvent({
    this.paymentId,
    this.payerId,
    this.token,
    required this.isSuccess,
  });

  @override
  List<Object?> get props => [paymentId, payerId, token, isSuccess];
}