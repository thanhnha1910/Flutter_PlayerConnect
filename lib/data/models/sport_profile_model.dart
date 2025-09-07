import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';
import 'tag_model.dart';

part 'sport_profile_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SportProfileModel extends Equatable {
  final int? id;
  final int sportId;
  final String sportName;
  final String? sportIcon;
  final int skill;
  final List<TagModel> tags;

  const SportProfileModel({
    this.id,
    required this.sportId,
    required this.sportName,
    this.sportIcon,
    required this.skill,
    required this.tags,
  });

  factory SportProfileModel.fromJson(Map<String, dynamic> json) =>
      _$SportProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$SportProfileModelToJson(this);

  SportProfileModel copyWith({
    int? id,
    int? sportId,
    String? sportName,
    String? sportIcon,
    int? skill,
    List<TagModel>? tags,
  }) {
    return SportProfileModel(
      id: id ?? this.id,
      sportId: sportId ?? this.sportId,
      sportName: sportName ?? this.sportName,
      sportIcon: sportIcon ?? this.sportIcon,
      skill: skill ?? this.skill,
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sportId,
        sportName,
        sportIcon,
        skill,
        tags,
      ];
}

@JsonSerializable(explicitToJson: true)
class SportProfileRequest extends Equatable {
  final int? sportId;
  final String sportName;
  final String? sportIcon;
  final int skill;
  final List<TagRequest> tags;

  const SportProfileRequest({
    this.sportId,
    required this.sportName,
    this.sportIcon,
    required this.skill,
    required this.tags,
  });

  factory SportProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$SportProfileRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SportProfileRequestToJson(this);

  @override
  List<Object?> get props => [
        sportId,
        sportName,
        sportIcon,
        skill,
        tags,
      ];
}