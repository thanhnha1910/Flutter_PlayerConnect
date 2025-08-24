import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/booking_model.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, Booking>> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String? notes,
  });

  Future<Either<Failure, List<TimeSlot>>> checkAvailability({
    required int fieldId,
    required DateTime date,
  });

  Future<Either<Failure, List<Booking>>> getUserBookings({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Either<Failure, Booking>> cancelBooking({
    required int bookingId,
    String? cancellationReason,
  });

  Future<Either<Failure, Booking>> getBookingById(int bookingId);
}