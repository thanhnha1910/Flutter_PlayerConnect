import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:player_connect/data/models/review_model.dart';

part 'location_details_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationDetailsModel extends Equatable {
  final String name;
  final String address;
  final List<ReviewModel>? reviews;

  const LocationDetailsModel({required this.name, required this.address, this.reviews});

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) => _$LocationDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailsModelToJson(this);

  @override
  List<Object?> get props => [
    name, address, reviews
  ];
}