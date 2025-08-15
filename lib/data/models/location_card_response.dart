import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'location_card_response.g.dart';

@JsonSerializable(explicitToJson: true)
class LocationCardResponse extends Equatable {
  @JsonKey(name: 'locationId', fromJson: _parseLocationId)
  final String locationId;
  final String locationName;
  final String slug;
  final String address;
  final String? mainImageUrl;
  final int fieldCount;
  @JsonKey(fromJson: _parseNullableDouble)
  final double? averageRating;
  @JsonKey(fromJson: _parseNullableDouble)
  final double? startingPrice;
  final int bookingCount;
  final double? distance; // Distance from user's location (calculated on frontend)

  // Helper methods for safe parsing
  static String _parseLocationId(dynamic value) {
    if (value == null) return '0';
    return value.toString();
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  const LocationCardResponse({
    required this.locationId,
    required this.locationName,
    required this.slug,
    required this.address,
    this.mainImageUrl,
    required this.fieldCount,
    this.averageRating,
    this.startingPrice,
    required this.bookingCount,
    this.distance,
  });

  factory LocationCardResponse.fromJson(Map<String, dynamic> json) =>
      _$LocationCardResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LocationCardResponseToJson(this);

  LocationCardResponse copyWith({
    String? locationId,
    String? locationName,
    String? slug,
    String? address,
    String? mainImageUrl,
    int? fieldCount,
    double? averageRating,
    double? startingPrice,
    int? bookingCount,
    double? distance,
  }) {
    return LocationCardResponse(
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      slug: slug ?? this.slug,
      address: address ?? this.address,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      fieldCount: fieldCount ?? this.fieldCount,
      averageRating: averageRating ?? this.averageRating,
      startingPrice: startingPrice ?? this.startingPrice,
      bookingCount: bookingCount ?? this.bookingCount,
      distance: distance ?? this.distance,
    );
  }

  @override
  List<Object?> get props => [
        locationId,
        locationName,
        slug,
        address,
        mainImageUrl,
        fieldCount,
        averageRating,
        startingPrice,
        bookingCount,
        distance,
      ];
}