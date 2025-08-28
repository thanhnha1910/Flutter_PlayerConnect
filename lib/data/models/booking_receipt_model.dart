import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'booking_receipt_model.g.dart';

@JsonSerializable(explicitToJson: true)
class BookingReceiptModel extends Equatable {
  @JsonKey(name: 'bookingId')
  final int id;
  
  @JsonKey(name: 'fromTime')
  final DateTime startTime;
  
  @JsonKey(name: 'toTime')
  final DateTime endTime;
  
  final int? slots;
  final String status;
  final String? paymentToken;
  
  // User information
  final int? userId;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  
  // Field information
  final int? fieldId;
  final String? fieldName;
  final String? fieldDescription;
  final double? hourlyRate;
  
  // Location information
  final String? locationName;
  final String? locationAddress;
  
  // Field type and category
  final String? fieldTypeName;
  final String? fieldCategoryName;
  
  // Calculated values
  final double? totalPrice;
  final int? durationHours;
  
  // Open match information (if exists)
  final OpenMatchSummary? openMatch;

  const BookingReceiptModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.slots,
    required this.status,
    this.paymentToken,
    this.userId,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.fieldId,
    this.fieldName,
    this.fieldDescription,
    this.hourlyRate,
    this.locationName,
    this.locationAddress,
    this.fieldTypeName,
    this.fieldCategoryName,
    this.totalPrice,
    this.durationHours,
    this.openMatch,
  });

  factory BookingReceiptModel.fromJson(Map<String, dynamic> json) {
    // Handle DateTime parsing for fromTime and toTime
    DateTime parseDateTime(dynamic value) {
      if (value is String) {
        return DateTime.parse(value);
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      }
      throw ArgumentError('Invalid datetime format: $value');
    }

    return BookingReceiptModel(
      id: json['bookingId'] as int,
      startTime: parseDateTime(json['fromTime']),
      endTime: parseDateTime(json['toTime']),
      slots: json['slots'] as int?,
      status: json['status'] as String,
      paymentToken: json['paymentToken'] as String?,
      userId: json['userId'] as int?,
      customerName: json['customerName'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerPhone: json['customerPhone'] as String?,
      fieldId: json['fieldId'] as int?,
      fieldName: json['fieldName'] as String?,
      fieldDescription: json['fieldDescription'] as String?,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      locationAddress: json['locationAddress'] as String?,
      fieldTypeName: json['fieldTypeName'] as String?,
      fieldCategoryName: json['fieldCategoryName'] as String?,
      totalPrice: (json['totalPrice'] as num?)?.toDouble(),
      durationHours: json['durationHours'] as int?,
      openMatch: json['openMatch'] != null 
          ? OpenMatchSummary.fromJson(json['openMatch'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => _$BookingReceiptModelToJson(this);

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
        startTime,
        endTime,
        slots,
        status,
        paymentToken,
        userId,
        customerName,
        customerEmail,
        customerPhone,
        fieldId,
        fieldName,
        fieldDescription,
        hourlyRate,
        locationName,
        locationAddress,
        fieldTypeName,
        fieldCategoryName,
        totalPrice,
        durationHours,
        openMatch,
      ];
}

@JsonSerializable(explicitToJson: true)
class OpenMatchSummary extends Equatable {
  final int id;
  final String sportType;
  final int slotsNeeded;
  final String status;

  const OpenMatchSummary({
    required this.id,
    required this.sportType,
    required this.slotsNeeded,
    required this.status,
  });

  factory OpenMatchSummary.fromJson(Map<String, dynamic> json) =>
      _$OpenMatchSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$OpenMatchSummaryToJson(this);

  @override
  List<Object?> get props => [id, sportType, slotsNeeded, status];
}

@JsonSerializable(explicitToJson: true)
class BatchBookingReceiptModel extends Equatable {
  final List<BookingReceiptModel> bookings;
  final int totalBookings;
  final double totalAmount;
  final bool isBatch;
  final String message;

  const BatchBookingReceiptModel({
    required this.bookings,
    required this.totalBookings,
    required this.totalAmount,
    required this.isBatch,
    required this.message,
  });

  factory BatchBookingReceiptModel.fromJson(Map<String, dynamic> json) {
    return BatchBookingReceiptModel(
      bookings: (json['bookings'] as List<dynamic>)
          .map((e) => BookingReceiptModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalBookings: json['totalBookings'] as int,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      isBatch: json['isBatch'] as bool,
      message: json['message'] as String,
    );
  }

  Map<String, dynamic> toJson() => _$BatchBookingReceiptModelToJson(this);

  @override
  List<Object?> get props => [bookings, totalBookings, totalAmount, isBatch, message];
}