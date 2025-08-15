import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'sport_model.g.dart';

@JsonSerializable(explicitToJson: true)
class SportModel extends Equatable {
  final int id;
  final String name;
  final String sportCode;
  final String? icon;
  final bool isActive;

  const SportModel({
    required this.id,
    required this.name,
    required this.sportCode,
    this.icon,
    required this.isActive,
  });

  factory SportModel.fromJson(Map<String, dynamic> json) =>
      _$SportModelFromJson(json);

  Map<String, dynamic> toJson() => _$SportModelToJson(this);

  SportModel copyWith({
    int? id,
    String? name,
    String? sportCode,
    String? icon,
    bool? isActive,
  }) {
    return SportModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sportCode: sportCode ?? this.sportCode,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sportCode,
        icon,
        isActive,
      ];
}