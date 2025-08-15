import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'location_map_model.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationMapModel extends Equatable {
  @JsonKey(name: 'locationId', fromJson: _parseLocationId)
  final String locationId;
  final String name;
  final String slug;
  final String address;
  @JsonKey(fromJson: _parseDouble)
  final double latitude;
  @JsonKey(fromJson: _parseDouble)
  final double longitude;
  final int fieldCount;
  @JsonKey(fromJson: _parseNullableDouble)
  final double? averageRating;
  final String? thumbnailImageUrl;
  final double? distance;

  // Helper methods for safe parsing - Enhanced for BigDecimal compatibility
  static String _parseLocationId(dynamic value) {
    if (value == null) return '0';
    // Handle both String and numeric types (Long from backend)
    if (value is num) return value.toString();
    if (value is String) return value;
    return value.toString();
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    // Handle numeric types directly
    if (value is num) return value.toDouble();
    // Handle BigDecimal serialized as string
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
      // Handle potential BigDecimal string format issues
      final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    // Handle numeric types directly
    if (value is num) return value.toDouble();
    // Handle BigDecimal serialized as string
    if (value is String) {
      if (value.isEmpty) return null;
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
      // Handle potential BigDecimal string format issues
      final cleaned = value.replaceAll(RegExp(r'[^0-9.-]'), '');
      return double.tryParse(cleaned);
    }
    return null;
  } // Distance from user's location (calculated on frontend)

  const LocationMapModel({
    required this.locationId,
    required this.name,
    required this.slug,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.fieldCount,
    this.averageRating,
    this.thumbnailImageUrl,
    this.distance,
  });

  factory LocationMapModel.fromJson(Map<String, dynamic> json) => _$LocationMapModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationMapModelToJson(this);

  LocationMapModel copyWith({
    String? locationId,
    String? name,
    String? slug,
    String? address,
    double? latitude,
    double? longitude,
    int? fieldCount,
    double? averageRating,
    String? thumbnailImageUrl,
    double? distance,
  }) {
    return LocationMapModel(
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fieldCount: fieldCount ?? this.fieldCount,
      averageRating: averageRating ?? this.averageRating,
      thumbnailImageUrl: thumbnailImageUrl ?? this.thumbnailImageUrl,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
        locationId,
        name,
        slug,
        address,
        latitude,
        longitude,
        fieldCount,
        averageRating,
        thumbnailImageUrl,
        distance,
      ];
}