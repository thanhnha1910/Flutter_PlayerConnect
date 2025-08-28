// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentRegistrationRequest _$TournamentRegistrationRequestFromJson(
  Map<String, dynamic> json,
) => TournamentRegistrationRequest(
  tournamentId: (json['tournamentId'] as num).toInt(),
  teamId: (json['teamId'] as num).toInt(),
);

Map<String, dynamic> _$TournamentRegistrationRequestToJson(
  TournamentRegistrationRequest instance,
) => <String, dynamic>{
  'tournamentId': instance.tournamentId,
  'teamId': instance.teamId,
};

TournamentRegistrationResponse _$TournamentRegistrationResponseFromJson(
  Map<String, dynamic> json,
) => TournamentRegistrationResponse(
  teamId: (json['teamId'] as num).toInt(),
  paymentUrl: json['payUrl'] as String?,
);

Map<String, dynamic> _$TournamentRegistrationResponseToJson(
  TournamentRegistrationResponse instance,
) => <String, dynamic>{
  'teamId': instance.teamId,
  'payUrl': instance.paymentUrl,
};

PaymentReceiptModel _$PaymentReceiptModelFromJson(Map<String, dynamic> json) =>
    PaymentReceiptModel(
      id: (json['id'] as num).toInt(),
      tournamentId: (json['tournamentId'] as num).toInt(),
      teamId: (json['teamId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      paidAt: json['paidAt'] == null
          ? null
          : DateTime.parse(json['paidAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PaymentReceiptModelToJson(
  PaymentReceiptModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'tournamentId': instance.tournamentId,
  'teamId': instance.teamId,
  'amount': instance.amount,
  'status': instance.status,
  'paymentMethod': instance.paymentMethod,
  'transactionId': instance.transactionId,
  'paidAt': instance.paidAt?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
