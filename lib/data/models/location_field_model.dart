import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:player_connect/data/models/booking_model.dart';

part 'location_field_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationFieldModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int hourlyRate;
  final List<BookingModel>? bookings;

  const LocationFieldModel({
    required this.id,
    required this.name,
    this.description,
    required this.hourlyRate,
    this.bookings
});

  factory LocationFieldModel.fromJson(Map<String, dynamic> json) => _$LocationFieldModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationFieldModelToJson(this);

  @override
  List<Object?> get props => [];

}
