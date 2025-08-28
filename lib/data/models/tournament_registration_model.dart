import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'tournament_model.dart';
import 'team_model.dart';

part 'tournament_registration_model.g.dart';

@JsonSerializable()
class TournamentRegistrationRequest extends Equatable {
  final int tournamentId;
  final int teamId;

  const TournamentRegistrationRequest({
    required this.tournamentId,
    required this.teamId,
  });

  factory TournamentRegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$TournamentRegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentRegistrationRequestToJson(this);

  @override
  List<Object?> get props => [
        tournamentId,
        teamId,
      ];
}

@JsonSerializable()
class TournamentRegistrationResponse extends Equatable {
  final int teamId;
  @JsonKey(name: 'payUrl')
  final String? paymentUrl;

  const TournamentRegistrationResponse({
    required this.teamId,
    this.paymentUrl,
  });

  factory TournamentRegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$TournamentRegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentRegistrationResponseToJson(this);

  @override
  List<Object?> get props => [
        teamId,
        paymentUrl,
      ];
}

@JsonSerializable()
class PaymentReceiptModel extends Equatable {
  final int id;
  final int tournamentId;
  final int teamId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final DateTime? paidAt;
  final DateTime createdAt;

  const PaymentReceiptModel({
    required this.id,
    required this.tournamentId,
    required this.teamId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.paidAt,
    required this.createdAt,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$PaymentReceiptModelFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentReceiptModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        tournamentId,
        teamId,
        amount,
        status,
        paymentMethod,
        transactionId,
        paidAt,
        createdAt,
      ];
}