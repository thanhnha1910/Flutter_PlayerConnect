import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:player_connect/data/models/review_model.dart';

part 'location_details_model.g.dart';

@JsonSerializable(explicitToJson: true)
class FieldTypeModel extends Equatable {
  final int? typeId;
  final String? name;
  final int? teamCapacity;
  final int? maxCapacity;
  final int? hourlyRate;
  final String? description;
  final int? locationId;
  final String? locationName;
  final List<FieldModel>? fields;

  const FieldTypeModel({
    this.typeId,
    this.name,
    this.teamCapacity,
    this.maxCapacity,
    this.hourlyRate,
    this.description,
    this.locationId,
    this.locationName,
    this.fields,
  });

  factory FieldTypeModel.fromJson(Map<String, dynamic> json) => _$FieldTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$FieldTypeModelToJson(this);

  @override
  List<Object?> get props => [
    typeId, name, teamCapacity, maxCapacity, hourlyRate, description, locationId, locationName, fields
  ];
}

@JsonSerializable(explicitToJson: true)
class FieldModel extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final int? hourlyRate;
  final String? thumbnailUrl;
  final String? imageGallery;

  const FieldModel({
    this.id,
    this.name,
    this.description,
    this.hourlyRate,
    this.thumbnailUrl,
    this.imageGallery,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) => _$FieldModelFromJson(json);
  Map<String, dynamic> toJson() => _$FieldModelToJson(this);

  @override
  List<Object?> get props => [
    id, name, description, hourlyRate, thumbnailUrl, imageGallery
  ];
}

@JsonSerializable(explicitToJson: true)
class LocationDetailsModel extends Equatable {
  final String name;
  final String address;
  final String? description;
  final List<FieldTypeModel>? fieldTypes;
  final List<ReviewModel>? reviews;

  const LocationDetailsModel({
    required this.name, 
    required this.address, 
    this.description,
    this.fieldTypes,
    this.reviews
  });

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) => _$LocationDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailsModelToJson(this);

  @override
  List<Object?> get props => [
    name, address, description, fieldTypes, reviews
  ];
}