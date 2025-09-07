import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'tag_model.g.dart';

@JsonSerializable(explicitToJson: true)
class TagModel extends Equatable {
  final int id;
  final String name;
  final String tagType;
  final int? sportId;

  const TagModel({
    required this.id,
    required this.name,
    required this.tagType,
    this.sportId,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) =>
      _$TagModelFromJson(json);

  Map<String, dynamic> toJson() => _$TagModelToJson(this);

  TagModel copyWith({
    int? id,
    String? name,
    String? tagType,
    int? sportId,
  }) {
    return TagModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tagType: tagType ?? this.tagType,
      sportId: sportId ?? this.sportId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        tagType,
        sportId,
      ];
}

@JsonSerializable(explicitToJson: true)
class TagRequest extends Equatable {
  final int? tagId;
  final String tagName;
  final String tagType;

  const TagRequest({
    this.tagId,
    required this.tagName,
    required this.tagType,
  });

  factory TagRequest.fromJson(Map<String, dynamic> json) =>
      _$TagRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TagRequestToJson(this);

  @override
  List<Object?> get props => [
        tagId,
        tagName,
        tagType,
      ];
}