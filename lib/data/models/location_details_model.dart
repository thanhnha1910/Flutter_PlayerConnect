import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:player_connect/data/models/booking_model.dart';
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

  factory FieldTypeModel.fromJson(Map<String, dynamic> json) =>
      _$FieldTypeModelFromJson(json);
  Map<String, dynamic> toJson() => _$FieldTypeModelToJson(this);

  FieldTypeModel copyWith({
    int? typeId,
    String? name,
    int? teamCapacity,
    int? maxCapacity,
    int? hourlyRate,
    String? description,
    int? locationId,
    String? locationName,
    List<FieldModel>? fields,
  }) {
    return FieldTypeModel(
      typeId: typeId ?? this.typeId,
      name: name ?? this.name,
      teamCapacity: teamCapacity ?? this.teamCapacity,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      description: description ?? this.description,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      fields: fields ?? this.fields,
    );
  }

  @override
  List<Object?> get props => [
        typeId,
        name,
        teamCapacity,
        maxCapacity,
        hourlyRate,
        description,
        locationId,
        locationName,
        fields
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
  final List<BookingModel>? bookings;

  const FieldModel({
    this.id,
    this.name,
    this.description,
    this.hourlyRate,
    this.thumbnailUrl,
    this.imageGallery,
    this.bookings,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) =>
      _$FieldModelFromJson(json);
  Map<String, dynamic> toJson() => _$FieldModelToJson(this);

  FieldModel copyWith({
    int? id,
    String? name,
    String? description,
    int? hourlyRate,
    String? thumbnailUrl,
    String? imageGallery,
    List<BookingModel>? bookings,
  }) {
    return FieldModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      imageGallery: imageGallery ?? this.imageGallery,
      bookings: bookings ?? this.bookings,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, description, hourlyRate, thumbnailUrl, imageGallery, bookings];
}

@JsonSerializable(explicitToJson: true)
class LocationDetailsModel extends Equatable {
  final String name;
  final String address;
  final String? description;
  final List<FieldTypeModel>? fieldTypes;
  final List<ReviewModel>? reviews;

  const LocationDetailsModel(
      {required this.name,
      required this.address,
      this.description,
      this.fieldTypes,
      this.reviews});

  factory LocationDetailsModel.fromJson(Map<String, dynamic> json) =>
      _$LocationDetailsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationDetailsModelToJson(this);

  LocationDetailsModel copyWith({
    String? name,
    String? address,
    String? description,
    List<FieldTypeModel>? fieldTypes,
    List<ReviewModel>? reviews,
  }) {
    return LocationDetailsModel(
      name: name ?? this.name,
      address: address ?? this.address,
      description: description ?? this.description,
      fieldTypes: fieldTypes ?? this.fieldTypes,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  List<Object?> get props => [name, address, description, fieldTypes, reviews];
}