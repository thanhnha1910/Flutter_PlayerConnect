import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

@injectable
class GetUserBookingsUseCase {
  final BookingRepository repository;

  GetUserBookingsUseCase(this.repository);

  Future<Either<Failure, List<Booking>>> call({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    return await repository.getUserBookings(
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}