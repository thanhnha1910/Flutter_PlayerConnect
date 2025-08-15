import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class LocationPermissionService {
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }
    
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentLocation() async {
    bool hasPermission = await hasLocationPermission();
    if (!hasPermission) {
      hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        return null;
      }
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: AndroidSettings()
      );
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}