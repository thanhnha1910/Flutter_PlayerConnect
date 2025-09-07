import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'booking_model.g.dart';

@JsonSerializable()
class BookingModel extends Equatable {
  final String? id;
  final int? fieldId;
  @JsonKey(name: 'fromTime')
  final DateTime? startTime;
  @JsonKey(name: 'toTime')
  final DateTime? endTime;
  final String? status;
  final String? customerName;
  final String? customerPhone;
  final num? basePrice;
  final num? discountPercent;
  final num? discountAmount;
  final num? totalPrice;
  final bool? booked;

  const BookingModel({
    this.id,
    this.fieldId,
    this.startTime,
    this.endTime,
    this.status,
    this.customerName,
    this.customerPhone,
    this.basePrice,
    this.discountPercent,
    this.discountAmount,
    this.totalPrice,
    this.booked,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) =>
      _$BookingModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        fieldId,
        startTime,
        endTime,
        status,
        customerName,
        customerPhone,
        basePrice,
        discountPercent,
        discountAmount,
        totalPrice,
        booked,
      ];
}