part of 'booking_bloc.dart';
abstract class BookingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final int fieldId;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String? notes;

  CreateBookingEvent({
    required this.fieldId,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    this.notes,
  });

  @override
  List<Object?> get props => [fieldId, startTime, endTime, totalPrice, notes];
}

class CheckAvailabilityEvent extends BookingEvent {
  final int fieldId;
  final DateTime date;

  CheckAvailabilityEvent({
    required this.fieldId,
    required this.date,
  });

  @override
  List<Object?> get props => [fieldId, date];
}