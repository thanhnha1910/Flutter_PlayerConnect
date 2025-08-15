import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'booking_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookingModel extends Equatable {
  final int id;
  final int fieldId;
  final String fieldName;
  final DateTime startTime;
  final DateTime endTime;
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'cancelled', 'completed'
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const BookingModel({
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

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  Duration get duration => endTime.difference(startTime);

  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Chờ xác nhận';
      case 'confirmed':
        return 'Đã xác nhận';
      case 'cancelled':
        return 'Đã hủy';
      case 'completed':
        return 'Hoàn thành';
      default:
        return 'Không xác định';
    }
  }

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

@JsonSerializable(explicitToJson: true)
class TimeSlot extends Equatable {
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final double pricePerHour;
  final String? bookedBy;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    required this.pricePerHour,
    this.bookedBy,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) =>
      _$TimeSlotFromJson(json);

  Map<String, dynamic> toJson() => _$TimeSlotToJson(this);

  String get timeDisplay {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        isAvailable,
        pricePerHour,
        bookedBy,
      ];
}
