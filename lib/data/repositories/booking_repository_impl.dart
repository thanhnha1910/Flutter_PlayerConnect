import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_remote_datasource.dart';
import '../models/booking_model.dart';

@LazySingleton(as: BookingRepository)
class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Booking>> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    required double totalPrice,
    String? notes,
  }) async {
    try {
      final model = await remoteDataSource.createBooking(
        fieldId: fieldId,
        startTime: startTime,
        endTime: endTime,
        totalPrice: totalPrice,
        notes: notes,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> checkAvailability({
    required int fieldId,
    required DateTime date,
  }) async {
    try {
      final slots = await remoteDataSource.getAvailableTimeSlots(
        fieldId: fieldId,
        date: date,
      );
      return Right(slots);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to check availability: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Booking>>> getUserBookings({
    String? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final bookingModels = await remoteDataSource.getUserBookings(
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );
      final bookings = bookingModels.map((model) => model.toEntity()).toList();
      return Right(bookings);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get user bookings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Booking>> cancelBooking({
    required int bookingId,
    String? cancellationReason,
  }) async {
    try {
      final model = await remoteDataSource.cancelBooking(
        bookingId: bookingId,
        cancellationReason: cancellationReason,
      );
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to cancel booking: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Booking>> getBookingById(int bookingId) async {
    try {
      final model = await remoteDataSource.getBookingById(bookingId);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to get booking: ${e.toString()}'));
    }
  }
}
