part of 'payment_bloc.dart';

abstract class PaymentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentInitiated extends PaymentState {
  final String approvalUrl;
  final int paymentId;

  PaymentInitiated({
    required this.approvalUrl,
    required this.paymentId,
  });

  @override
  List<Object?> get props => [approvalUrl, paymentId];
}

class PaymentStatusLoaded extends PaymentState {
  final Payment payment;

  PaymentStatusLoaded(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentSuccess extends PaymentState {
  final Payment payment;

  PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class PaymentCancelled extends PaymentState {
  final String? reason;

  PaymentCancelled({this.reason});

  @override
  List<Object?> get props => [reason];
}

class PaymentFailure extends PaymentState {
  final String message;

  PaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}