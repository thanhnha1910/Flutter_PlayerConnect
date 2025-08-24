import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

@injectable
class CreateBookingUseCase {
  final BookingRepository repository;

  CreateBookingUseCase(this.repository);

  Future<Either<Failure, Booking>> call({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String? notes,
  }) async {
    // Validation
    if (startTime.isAfter(endTime)) {
      return Left(ValidationFailure('Thời gian bắt đầu phải trước thời gian kết thúc'));
    }

    if (startTime.isBefore(DateTime.now())) {
      return Left(ValidationFailure('Không thể đặt sân cho thời gian trong quá khứ'));
    }

    final duration = endTime.difference(startTime);
    if (duration.inMinutes < 30) {
      return Left(ValidationFailure('Thời gian đặt sân tối thiểu là 30 phút'));
    }

    if (totalPrice <= 0) {
      return Left(ValidationFailure('Tổng giá phải lớn hơn 0'));
    }

    return await repository.createBooking(
      fieldId: fieldId,
      startTime: startTime,
      endTime: endTime,
      totalPrice: totalPrice,
      notes: notes,
    );
  }
}