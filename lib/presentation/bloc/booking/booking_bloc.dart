import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/booking_model.dart';
import '../../../domain/entities/booking.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/auth/getpaymentstatus_usecase.dart';
import '../../../domain/usecases/auth/initiatepayment_usecase.dart';
import '../../../domain/usecases/booking/check_availability_usecase.dart';
import '../../../domain/usecases/booking/create_booking_usecase.dart';

part 'booking_event.dart';
part 'booking_state.dart';
@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CreateBookingUseCase createBookingUseCase;
  final CheckAvailabilityUseCase checkAvailabilityUseCase;

  BookingBloc({
    required this.createBookingUseCase,
    required this.checkAvailabilityUseCase,
  }) : super(BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<CheckAvailabilityEvent>(_onCheckAvailability);
  }

  Future<void> _onCreateBooking(
      CreateBookingEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());
    final result = await createBookingUseCase(
      fieldId: event.fieldId,
      startTime: event.startTime,
      endTime: event.endTime,
      totalPrice: event.totalPrice,
      notes: event.notes,
    );

    result.fold(
          (failure) => emit(BookingFailure(failure.message ?? "Unexpected error")),
          (booking) => emit(BookingCreated(booking)),
    );
  }

  Future<void> _onCheckAvailability(
      CheckAvailabilityEvent event,
      Emitter<BookingState> emit,
      ) async {
    emit(BookingLoading());
    final result = await checkAvailabilityUseCase(
      fieldId: event.fieldId,
      date: event.date,
    );

    result.fold(
          (failure) => emit(BookingFailure(failure.message ?? "Unexpected error")),
          (timeSlots) => emit(AvailabilityChecked(timeSlots)),
    );
  }
}