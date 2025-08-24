part of 'booking_bloc.dart';
abstract class BookingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingCreated extends BookingState {
  final Booking booking;

  BookingCreated(this.booking);

  @override
  List<Object?> get props => [booking];
}

class AvailabilityChecked extends BookingState {
  final List<TimeSlot> timeSlots;

  AvailabilityChecked(this.timeSlots);

  @override
  List<Object?> get props => [timeSlots];
}

class BookingFailure extends BookingState {
  final String message;

  BookingFailure(this.message);

  @override
  List<Object?> get props => [message];
}