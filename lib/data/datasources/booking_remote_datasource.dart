import '../models/booking_model.dart';
import '../../domain/entities/booking.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String? notes,
  });

  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int fieldId,
    required DateTime date,
  });

  Future<List<BookingModel>> getUserBookings({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<BookingModel> cancelBooking({
    required int bookingId,
    String? cancellationReason,
  });

  Future<BookingModel> getBookingById(int bookingId);
}