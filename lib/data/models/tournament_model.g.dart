// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TournamentModel _$TournamentModelFromJson(Map<String, dynamic> json) =>
    TournamentModel(
      id: (json['tournamentId'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String,
      slug: json['slug'] as String,
      image: json['image'] as String?,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      registrationDeadline: json['registrationDeadline'] == null
          ? null
          : DateTime.parse(json['registrationDeadline'] as String),
      maxTeams: (json['slots'] as num).toInt(),
      currentTeams: (json['currentTeams'] as num?)?.toInt() ?? 0,
      registrationFee: (json['entryFee'] as num).toInt(),
      status: json['status'] as String,
      rules: json['rules'] as String?,
      prizes: (json['prize'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TournamentModelToJson(TournamentModel instance) =>
    <String, dynamic>{
      'tournamentId': instance.id,
      'name': instance.name,
      'description': instance.description,
      'slug': instance.slug,
      'image': instance.image,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'registrationDeadline': instance.registrationDeadline?.toIso8601String(),
      'slots': instance.maxTeams,
      'currentTeams': instance.currentTeams,
      'entryFee': instance.registrationFee,
      'status': instance.status,
      'rules': instance.rules,
      'prize': instance.prizes,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
