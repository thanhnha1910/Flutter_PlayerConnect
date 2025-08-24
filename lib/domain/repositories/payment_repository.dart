import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/payment.dart';
import '../entities/paymentapproval.dart';

abstract class PaymentRepository {
  Future<Either<Failure, PaymentApproval>> initiatePayment({
    required int payableId,
    required String payableType,
    required int amount,
  });

  Future<Either<Failure, Payment>> getPaymentDetail(int paymentId);
}