import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../entities/paymentapproval.dart';
import '../../repositories/payment_repository.dart';

@injectable
class InitiatePaymentUseCase {
  final PaymentRepository repository;

  InitiatePaymentUseCase(this.repository);

  Future<Either<Failure, PaymentApproval>> call({
    required int payableId,
    required String payableType,
    required int amount,
  }) async {
    return await repository.initiatePayment(
      payableId: payableId,
      payableType: payableType,
      amount: amount,
    );
  }
}