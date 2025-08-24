import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/paymentapproval.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

@LazySingleton(as: PaymentRepository)
class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaymentApproval>> initiatePayment({
    required int payableId,
    required String payableType,
    required int amount,
  }) async {
    try {
      final model = await remoteDataSource.initiatePayment(
        payableId: payableId,
        payableType: payableType,
        amount: amount,
      );
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentDetail(int paymentId) async {
    try {
      final model = await remoteDataSource.getPaymentDetail(paymentId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, Payment>> getPaymentStatus(int paymentId) async {
    try {
      final model = await remoteDataSource.getPaymentDetail(paymentId);
      return Right(model.toEntity());
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  // Helper để xử lý lỗi chi tiết hơn
  Failure _handleError(dynamic error) {
    // Có thể thêm logic phân loại lỗi dựa trên loại exception
    // Ví dụ: kiểm tra lỗi mạng, lỗi server, hoặc lỗi parse JSON
    if (error is Exception) {
      return ServerFailure(error.toString());
    }
    return ServerFailure('Unexpected error: $error');
  }
}