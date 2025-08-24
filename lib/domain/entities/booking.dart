import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final int id;
  final int fieldId;
  final String fieldName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Booking({
    required this.id,
    required this.fieldId,
    required this.fieldName,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    fieldId,
    fieldName,
    startTime,
    endTime,
    totalPrice,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
}