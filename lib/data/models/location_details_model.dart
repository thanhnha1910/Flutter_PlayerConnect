import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'location_details_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationDetailsModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final List<FieldModel>? fields;
  final List<ReviewModel>? reviews;

  const LocationDetailsModel({
    required this.id,
    required this.name,
    required this.address,
    this.fields,
    this.reviews,
  });

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailsModelToJson(this);

  @override
  List<Object?> get props => [id, name, address, fields, reviews];
}

@JsonSerializable()
class FieldModel extends Equatable {
  final int id;
  @JsonKey(name: 'field_name')
  final String name;
  @JsonKey(name: 'price_per_hour')
  final double pricePerHour;

  const FieldModel({
    required this.id,
    required this.name,
    required this.pricePerHour,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) =>
      _$FieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$FieldModelToJson(this);

  @override
  List<Object?> get props => [id, name, pricePerHour];
}

@JsonSerializable()
class ReviewModel extends Equatable {
  final int rating;
  final String comment;

  const ReviewModel({
    required this.rating,
    required this.comment,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  @override
  List<Object?> get props => [rating, comment];
}