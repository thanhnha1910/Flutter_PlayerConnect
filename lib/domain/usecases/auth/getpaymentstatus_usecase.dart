import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/payment.dart';
import '../../repositories/payment_repository.dart';

@injectable
class GetPaymentStatusUseCase {
  final PaymentRepository repository;

  GetPaymentStatusUseCase(this.repository);

  Future<Either<Failure, Payment>> call(int paymentId) async {
    return await repository.getPaymentDetail(paymentId);
  }
}