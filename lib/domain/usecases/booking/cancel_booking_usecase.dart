import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

@injectable
class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Either<Failure, Booking>> call({
    required int bookingId,
    String? cancellationReason,
  }) async {
    return await repository.cancelBooking(
      bookingId: bookingId,
      cancellationReason: cancellationReason,
    );
  }
}