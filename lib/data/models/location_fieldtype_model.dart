import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:player_connect/data/models/location_field_model.dart';

part 'location_fieldtype_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationFieldTypeModel extends Equatable {
  final int id;
  final String name;
  final int teamCapacity;
  final int maxCapacity;
  final int hourlyRate;
  final String? description;
  final List<LocationFieldModel>? fields;

  const LocationFieldTypeModel({
    required this.id,
    required this.name,
    required this.teamCapacity,
    required this.maxCapacity,
    required this.hourlyRate,
    this.description,
    this.fields
  });

  factory LocationFieldTypeModel.fromJson(Map<String, dynamic> json) => _$LocationFieldTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationFieldTypeModelToJson(this);

  @override
  List<Object?> get props => [];
}