import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'booking_model.dart';

part 'booking_request_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AdditionalPlayerModel extends Equatable {
  final int userId;
  final String? position;

  const AdditionalPlayerModel({
    required this.userId,
    this.position,
  });

  factory AdditionalPlayerModel.fromJson(Map<String, dynamic> json) =>
      _$AdditionalPlayerModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdditionalPlayerModelToJson(this);

  @override
  List<Object?> get props => [userId, position];
}

@JsonSerializable(explicitToJson: true)
class BookingRequestModel extends Equatable {
  final int fieldId;
  final DateTime fromTime;
  final DateTime toTime;
  final int? slots;
  final bool? findTeammates;
  final List<AdditionalPlayerModel>? additionalPlayers;

  const BookingRequestModel({
    required this.fieldId,
    required this.fromTime,
    required this.toTime,
    this.slots,
    this.findTeammates,
    this.additionalPlayers,
  });

  factory BookingRequestModel.fromJson(Map<String, dynamic> json) =>
      _$BookingRequestModelFromJson(json);

  Map<String, dynamic> toJson() {
    final json = _$BookingRequestModelToJson(this);
    // Ensure DateTime fields are serialized with UTC timezone indicator 'Z'
    json['fromTime'] = fromTime.toUtc().toIso8601String();
    json['toTime'] = toTime.toUtc().toIso8601String();
    return json;
  }

  Duration get duration => toTime.difference(fromTime);

  String get timeRange {
    final start = '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}';
    final end = '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  List<Object?> get props => [
        fieldId,
        fromTime,
        toTime,
        slots,
        findTeammates,
        additionalPlayers,
      ];
}

@JsonSerializable(explicitToJson: true)
class BookingResponseModel extends Equatable {
  final int bookingId;
  final String? status;
  final String? message;
  @JsonKey(name: 'payUrl')
  final String? paymentUrl;
  final String? paymentId;
  final BookingModel? booking;

  const BookingResponseModel({
    required this.bookingId,
    this.status,
    this.message,
    this.paymentUrl,
    this.paymentId,
    this.booking,
  });

  factory BookingResponseModel.fromJson(Map<String, dynamic> json) =>
      _$BookingResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookingResponseModelToJson(this);

  bool get isSuccess => status == 'success' || bookingId > 0;
  bool get requiresPayment => paymentUrl != null && paymentUrl!.isNotEmpty;

  @override
  String toString() {
    return 'BookingResponseModel(bookingId: $bookingId, status: $status, message: $message, paymentUrl: $paymentUrl, paymentId: $paymentId, booking: $booking)';
  }

  @override
  List<Object?> get props => [
        bookingId,
        status,
        message,
        paymentUrl,
        paymentId,
        booking,
      ];
}

@JsonSerializable(explicitToJson: true)
class PayPalPaymentModel extends Equatable {
  final String paymentId;
  final String payerId;
  final String status;
  final double amount;
  final String currency;
  final DateTime createdAt;

  const PayPalPaymentModel({
    required this.paymentId,
    required this.payerId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
  });

  factory PayPalPaymentModel.fromJson(Map<String, dynamic> json) =>
      _$PayPalPaymentModelFromJson(json);

  Map<String, dynamic> toJson() => _$PayPalPaymentModelToJson(this);

  bool get isCompleted => status == 'completed';
  bool get isApproved => status == 'approved';

  @override
  List<Object?> get props => [
        paymentId,
        payerId,
        status,
        amount,
        currency,
        createdAt,
      ];
}