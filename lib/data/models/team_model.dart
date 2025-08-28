import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'team_model.g.dart';

@JsonSerializable()
class TeamModel extends Equatable {
  @JsonKey(name: 'teamId')
  final int? id;
  final String name;
  final String? code;
  final String? description;
  final String? logo;
  final int? captainId;
  final UserModel? captain;
  final List<UserModel>? members;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const TeamModel({
    this.id,
    required this.name,
    this.code,
    this.description,
    this.logo,
    this.captainId,
    this.captain,
    this.members,
    this.createdAt,
    this.updatedAt,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) =>
      _$TeamModelFromJson(json);

  Map<String, dynamic> toJson() => _$TeamModelToJson(this);

  @override
  List<Object?> get props => [
        id,
        name,
        code,
        description,
        logo,
        captainId,
        captain,
        members,
        createdAt,
        updatedAt,
      ];

  TeamModel copyWith({
    int? id,
    String? name,
    String? code,
    String? description,
    String? logo,
    int? captainId,
    UserModel? captain,
    List<UserModel>? members,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      logo: logo ?? this.logo,
      captainId: captainId ?? this.captainId,
      captain: captain ?? this.captain,
      members: members ?? this.members,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}