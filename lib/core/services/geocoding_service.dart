import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class GeocodingService {
  /// Get address from coordinates
  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        // Build address string
        List<String> addressParts = [];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        
        return addressParts.join(', ');
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
    }
    
    return null;
  }
  
  /// Get current address from user's location
  static Future<String?> getCurrentAddress() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      return await getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current address: $e');
      return null;
    }
  }
  
  /// Get short address (street + district) with improved accuracy
  static Future<String?> getShortAddress(double latitude, double longitude) async {
    try {
      // Get multiple placemarks for better accuracy
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        print('=== GEOCODING DEBUG INFO ===');
        print('Total placemarks found: ${placemarks.length}');
        
      
        
        // Try to find the best placemark with most detailed information
        Placemark? bestPlace;
        int bestScore = -1;
        
        for (int i = 0; i < placemarks.length; i++) {
          Placemark place = placemarks[i];
          int score = 0;
          
          // Score based on available information
          if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) score += 10;
          if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) score += 8;
          if (place.subLocality != null && place.subLocality!.isNotEmpty) score += 6;
          if (place.locality != null && place.locality!.isNotEmpty) score += 4;
          if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) score += 2;
          if (place.street != null && place.street!.isNotEmpty) score += 1;
          
          print('Placemark $i score: $score');
          
          if (score > bestScore) {
            bestScore = score;
            bestPlace = place;
          }
        }
        
        // Fallback to first placemark if no scored one found
        bestPlace ??= placemarks[0];
        
        print('Selected placemark with score: $bestScore');
        print('Selected placemark index: ${placemarks.indexOf(bestPlace)}');
        
        // Build address with priority: street number + street name, ward, district
        List<String> addressParts = [];
        
        // Strategy 1: Try to build from thoroughfare components
        if (bestPlace.subThoroughfare != null && bestPlace.subThoroughfare!.isNotEmpty &&
            bestPlace.thoroughfare != null && bestPlace.thoroughfare!.isNotEmpty) {
          addressParts.add('${bestPlace.subThoroughfare} ${bestPlace.thoroughfare}');
        } else if (bestPlace.thoroughfare != null && bestPlace.thoroughfare!.isNotEmpty) {
          addressParts.add(bestPlace.thoroughfare!);
        } else if (bestPlace.street != null && bestPlace.street!.isNotEmpty) {
          // Strategy 2: Use street if thoroughfare is not available
          addressParts.add(bestPlace.street!);
        }
        
        // Add ward/commune (sublocality) - this is often missing in Vietnam
        if (bestPlace.subLocality != null && bestPlace.subLocality!.isNotEmpty) {
          addressParts.add(bestPlace.subLocality!);
        }
        
        // Add district (subAdministrativeArea) - this is usually available
        if (bestPlace.subAdministrativeArea != null && bestPlace.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(bestPlace.subAdministrativeArea!);
        }
        
        // If we still don't have enough info, try alternative approaches
        if (addressParts.length < 2) {
          // Try to extract more info from name field
          if (bestPlace.name != null && bestPlace.name!.isNotEmpty && 
              !addressParts.contains(bestPlace.name)) {
            // Check if name contains useful address info
            if (bestPlace.name!.contains('Đường') || bestPlace.name!.contains('Phường') || 
                bestPlace.name!.contains('Quận') || bestPlace.name!.contains('/')) {
              addressParts.insert(0, bestPlace.name!);
            }
          }
        }
        
        String result = addressParts.isNotEmpty ? addressParts.join(', ') : 'Unknown location';
        print('Final geocoded address: $result');
        
        // If result is still too generic, try to get more specific info
        if (result == bestPlace.subAdministrativeArea || 
            (addressParts.length == 1 && addressParts[0] == bestPlace.subAdministrativeArea)) {
          print('Address too generic, trying alternative approach...');
          return await _getAlternativeAddress(latitude, longitude, placemarks);
        }
        
        return result;
      }
    } catch (e) {
      print('Error getting short address: $e');
    }
    
    return null;
  }
  
  /// Get alternative address using different approach
  static Future<String?> _getAlternativeAddress(double latitude, double longitude, List<Placemark> originalPlacemarks) async {
    try {
      print('Trying alternative geocoding approach...');
      
      // Try with slightly different coordinates to get different results
      List<Future<List<Placemark>>> futures = [
        placemarkFromCoordinates(latitude + 0.0001, longitude),
        placemarkFromCoordinates(latitude - 0.0001, longitude),
        placemarkFromCoordinates(latitude, longitude + 0.0001),
        placemarkFromCoordinates(latitude, longitude - 0.0001),
        placemarkFromCoordinates(latitude + 0.0001, longitude + 0.0001),
      ];
      
      List<List<Placemark>> allResults = await Future.wait(futures);
      
      // Combine all placemarks including original ones
      List<Placemark> allPlacemarks = List.from(originalPlacemarks);
      for (List<Placemark> result in allResults) {
        allPlacemarks.addAll(result);
      }
      
      print('Total placemarks from alternative search: ${allPlacemarks.length}');
      
      // Find the most specific address from all placemarks
      String? bestAddress;
      int maxAddressParts = 0;
      
      for (int i = 0; i < allPlacemarks.length; i++) {
        Placemark place = allPlacemarks[i];
        List<String> parts = [];
        
        // Build address parts
        if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty &&
            place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          parts.add('${place.subThoroughfare} ${place.thoroughfare}');
        } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          parts.add(place.thoroughfare!);
        } else if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          parts.add(place.subLocality!);
        }
        
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          parts.add(place.subAdministrativeArea!);
        }
        
        // Prefer addresses with more specific parts
        if (parts.length > maxAddressParts && parts.length >= 2) {
          maxAddressParts = parts.length;
          bestAddress = parts.join(', ');
          print('Found better alternative address: $bestAddress (${parts.length} parts)');
        }
      }
      
      if (bestAddress != null && bestAddress.isNotEmpty) {
        print('Selected alternative address: $bestAddress');
        return bestAddress;
      }
      
      // Last resort: return the most detailed single component we can find
      for (Placemark place in allPlacemarks) {
        if (place.street != null && place.street!.isNotEmpty && place.street!.length > 10) {
          String fallback = place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty 
              ? '${place.street}, ${place.subAdministrativeArea}'
              : place.street!;
          print('Fallback address: $fallback');
          return fallback;
        }
      }
      
    } catch (e) {
      print('Error getting alternative address: $e');
    }
    
    return null;
  }
  
  /// Get alternative address using different approach
  static Future<String?> getAlternativeAddress(double latitude, double longitude) async {
    try {
      // Try with different approach - get multiple placemarks
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        
        List<String> addressParts = [];
        
        // Different address building strategy
        if (place.name != null && place.name!.isNotEmpty && !place.name!.contains('Unnamed')) {
          addressParts.add(place.name!);
        }
        
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        
        if (place.subAdministrativeArea != null && place.subAdministrativeArea!.isNotEmpty) {
          addressParts.add(place.subAdministrativeArea!);
        }
        
        String result = addressParts.join(', ');
        print('Alternative geocoded address: $result');
        return result.isNotEmpty ? result : null;
      }
    } catch (e) {
      print('Error getting alternative address: $e');
    }
    
    return null;
  }
}