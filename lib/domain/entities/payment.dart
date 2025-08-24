import 'package:equatable/equatable.dart';

class Payment extends Equatable {
  final int id;
  final int total;
  final String method; // PAYPAL
  final String status; // PENDING, SUCCESS, CANCELED, REFUNDED
  final int payableId;
  final String payableType; // BOOKING, TOURNAMENT

  const Payment({
    required this.id,
    required this.total,
    required this.method,
    required this.status,
    required this.payableId,
    required this.payableType,
  });

  @override
  List<Object?> get props => [id, total, method, status, payableId, payableType];
}
