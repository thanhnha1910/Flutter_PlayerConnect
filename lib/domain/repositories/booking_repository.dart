import '../../../data/models/booking_model.dart';
import '../../../data/models/booking_request_model.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class BookingRepository {
  Future<Either<Failure, BookingResponseModel>> createBooking(BookingRequestModel request);
  Future<Either<Failure, BookingResponseModel>> confirmPayment(String bookingId, PayPalPaymentModel payment);
  Future<Either<Failure, dynamic>> getBookingDetails(String bookingId);
  Future<Either<Failure, List<BookingModel>>> getUserBookings();
  Future<Either<Failure, void>> cancelBooking(String bookingId);
}