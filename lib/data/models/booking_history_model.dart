import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_history_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookingHistoryModel extends Equatable {
  @JsonKey(name: 'bookingId')
  final int id;
  final String fieldName;
  @JsonKey(name: 'fieldAddress')
  final String locationName;
  final String? sportType;
  @JsonKey(name: 'startTime')
  final DateTime bookingDate;
  final String? timeSlot;
  @JsonKey(name: 'totalPrice')
  final double? price;
  final String status;
  final String? notes;
  final DateTime? createdAt;
  @JsonKey(name: 'endTime')
  final DateTime? updatedAt;
  
  const BookingHistoryModel({
    required this.id,
    required this.fieldName,
    required this.locationName,
    this.sportType,
    required this.bookingDate,
    this.timeSlot,
    this.price,
    required this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });
  
  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) => _$BookingHistoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$BookingHistoryModelToJson(this);
  
  @override
  List<Object?> get props => [
    id, fieldName, locationName, sportType, bookingDate, timeSlot,
    price, status, notes, createdAt, updatedAt
  ];
}