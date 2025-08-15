import 'dart:math';
import 'package:geolocator/geolocator.dart';

class LocationUtils {
  /// Get current user location with permission handling
  static Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(accuracy: LocationAccuracy.best, timeLimit: Duration(seconds: 30)),
    );
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert to kilometers
  }

  /// Format distance for display
  static String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      return '${(distanceInKm * 1000).round()}m';
    } else if (distanceInKm < 10) {
      return '${distanceInKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceInKm.round()}km';
    }
  }

  /// Check if location is within a certain radius
  static bool isWithinRadius(
    double centerLat,
    double centerLng,
    double pointLat,
    double pointLng,
    double radiusInKm,
  ) {
    final distance = calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusInKm;
  }

  /// Get bearing between two points
  static double getBearing(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    final dLng = (endLng - startLng) * (pi / 180);
    final startLatRad = startLat * (pi / 180);
    final endLatRad = endLat * (pi / 180);

    final y = sin(dLng) * cos(endLatRad);
    final x = cos(startLatRad) * sin(endLatRad) -
        sin(startLatRad) * cos(endLatRad) * cos(dLng);

    final bearing = atan2(y, x) * (180 / pi);
    return (bearing + 360) % 360;
  }
}