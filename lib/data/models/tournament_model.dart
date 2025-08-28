import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tournament_model.g.dart';

@JsonSerializable()
class TournamentModel extends Equatable {
  @JsonKey(name: 'tournamentId')
  final int? id;
  final String name;
  final String description;
  final String slug;
  final String? image;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime? registrationDeadline;
  @JsonKey(name: 'slots')
  final int maxTeams;
  @JsonKey(defaultValue: 0)
  final int currentTeams;
  @JsonKey(name: 'entryFee')
  final int registrationFee;
  final String status;
  @JsonKey(ignore: true)
  final String? location;
  final String? rules;
  @JsonKey(name: 'prize')
  final int? prizes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TournamentModel({
    this.id,
    required this.name,
    required this.description,
    required this.slug,
    this.image,
    required this.startDate,
    required this.endDate,
    this.registrationDeadline,
    required this.maxTeams,
    this.currentTeams = 0,
    required this.registrationFee,
    required this.status,
    this.location,
    this.rules,
    this.prizes,
    this.createdAt,
    this.updatedAt,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) =>
      _$TournamentModelFromJson(json);

  Map<String, dynamic> toJson() => _$TournamentModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        slug,
        image,
        startDate,
        endDate,
        registrationDeadline,
        maxTeams,
        currentTeams,
        registrationFee,
        status,
        location,
        rules,
        prizes,
        createdAt,
        updatedAt,
      ];

  TournamentModel copyWith({
    int? id,
    String? name,
    String? description,
    String? slug,
    String? image,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? registrationDeadline,
    int? maxTeams,
    int? currentTeams,
    int? registrationFee,
    String? status,
    String? location,
    String? rules,
    int? prizes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      slug: slug ?? this.slug,
      image: image ?? this.image,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      maxTeams: maxTeams ?? this.maxTeams,
      currentTeams: currentTeams ?? this.currentTeams,
      registrationFee: registrationFee ?? this.registrationFee,
      status: status ?? this.status,
      location: location ?? this.location,
      rules: rules ?? this.rules,
      prizes: prizes ?? this.prizes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}