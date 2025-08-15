import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'location_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationModel extends Equatable {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? imageUrl;
  final double? rating;
  final int? reviewCount;
  final List<String>? amenities;
  final double? pricePerHour;
  final bool isActive;
  final double? distance; // Distance from user's location

  const LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.description,
    this.imageUrl,
    this.rating,
    this.reviewCount,
    this.amenities,
    this.pricePerHour,
    this.isActive = true,
    this.distance,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) =>
      _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  LocationModel copyWith({
    int? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? description,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    List<String>? amenities,
    double? pricePerHour,
    bool? isActive,
    double? distance,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      amenities: amenities ?? this.amenities,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      isActive: isActive ?? this.isActive,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        description,
        imageUrl,
        rating,
        reviewCount,
        amenities,
        pricePerHour,
        isActive,
        distance,
      ];
}
