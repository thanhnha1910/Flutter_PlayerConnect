import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/location_permission_service.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../data/models/location_details_model.dart'; // Add this
import '../../../domain/usecases/get_location_details_usecase.dart'; // Add this
import 'package:injectable/injectable.dart'; // Add this import

part 'location_event.dart';
part 'location_state.dart';

@injectable // Add this annotation
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final LocationPermissionService _locationPermissionService;
  final GetLocationDetailsUseCase _getLocationDetailsUseCase; // Add this
  
  LocationBloc({
    required LocationPermissionService locationPermissionService, // Make it required
    required GetLocationDetailsUseCase getLocationDetailsUseCase,
  }) : _locationPermissionService = locationPermissionService, // Remove null-aware operator
       _getLocationDetailsUseCase = getLocationDetailsUseCase,
       super(const LocationInitial()) {
    on<CheckAndRequestPermission>(_onCheckAndRequestPermission);
    on<LocationUpdated>(_onLocationUpdated);
    on<RefreshLocation>(_onRefreshLocation);
    on<LocationPermissionDeniedEvent>(_onLocationPermissionDenied);
    on<LoadLocationDetails>(_onLoadLocationDetails); // Add this
  }

  Future<void> _onCheckAndRequestPermission(
    CheckAndRequestPermission event,
    Emitter<LocationState> emit,
  ) async {
    print('📍 [LOCATION_BLOC] ========== CheckAndRequestPermission Started ==========');
    print('📍 [LOCATION_BLOC] Current state: ${state.runtimeType}');
    print('📍 [LOCATION_BLOC] Emitting LocationLoading...');
    emit(const LocationLoading());
    
    try {
      // Check if location services are enabled
      print('📍 [LOCATION_BLOC] Checking if location services are enabled...');
      final isLocationServiceEnabled = await _locationPermissionService.isLocationServiceEnabled();
      print('📍 [LOCATION_BLOC] Location services enabled: $isLocationServiceEnabled');
      
      if (!isLocationServiceEnabled) {
        print('📍 [LOCATION_BLOC] Location services disabled, emitting LocationServiceDisabled');
        emit(const LocationServiceDisabled('Location services are disabled. Please enable location services in settings.'));
        return;
      }

      // Check current permission status
      print('📍 [LOCATION_BLOC] Checking current permission status...');
      final permissionStatus = await Geolocator.checkPermission();
      print('📍 [LOCATION_BLOC] Current permission status: $permissionStatus');
      
      if (permissionStatus == LocationPermission.denied) {
        // Request permission
        print('📍 [LOCATION_BLOC] Permission denied, requesting permission...');
        final hasPermission = await _locationPermissionService.requestLocationPermission();
        print('📍 [LOCATION_BLOC] Permission request result: $hasPermission');
        if (!hasPermission) {
          print('📍 [LOCATION_BLOC] Permission denied by user, emitting LocationPermissionDenied');
          emit(const LocationPermissionDenied('Location permission was denied. Please grant permission to find nearby fields.'));
          return;
        }
      }
      
      if (permissionStatus == LocationPermission.deniedForever) {
        print('📍 [LOCATION_BLOC] Permission denied forever, emitting LocationPermissionDenied');
        emit(const LocationPermissionDenied('Location permission was permanently denied. Please enable it in settings.'));
        return;
      }
      
      // Get user location
      print('📍 [LOCATION_BLOC] Getting current location...');
      final userLocation = await _locationPermissionService.getCurrentLocation();
      print('📍 [LOCATION_BLOC] Got location: ${userLocation?.latitude}, ${userLocation?.longitude}');
      
      if (userLocation == null) {
        print('📍 [LOCATION_BLOC] Failed to get location, emitting LocationError');
        emit(const LocationError('Unable to get current location. Please try again.'));
        return;
      }
      
      // Get current address using geocoding
      String? currentAddress;
      try {
        print('=== LocationBloc: Getting address for coordinates: ${userLocation.latitude}, ${userLocation.longitude} ===');
        currentAddress = await GeocodingService.getShortAddress(
          userLocation.latitude,
          userLocation.longitude,
        );
        print('=== LocationBloc: Got address: $currentAddress ===');
      } catch (e) {
        print('Error getting current address: $e');
        // Fallback to coordinates display
        currentAddress = 'Lat: ${userLocation.latitude.toStringAsFixed(4)}, Lng: ${userLocation.longitude.toStringAsFixed(4)}';
      }
      
      print('📍 [LOCATION_BLOC] ========== SUCCESS: Emitting LocationAvailable ==========');
      print('📍 [LOCATION_BLOC] Final coordinates: ${userLocation.latitude}, ${userLocation.longitude}');
      print('📍 [LOCATION_BLOC] Final address: $currentAddress');
      
      emit(LocationAvailable(
        position: userLocation,
        address: currentAddress ?? 'Unknown location',
      ));
      
    } catch (e) {
      print('📍 [LOCATION_BLOC] ========== ERROR in CheckAndRequestPermission ==========');
      print('📍 [LOCATION_BLOC] Error: ${e.toString()}');
      print('📍 [LOCATION_BLOC] Error type: ${e.runtimeType}');
      emit(LocationError('Error checking location permission: ${e.toString()}'));
    }
  }

  void _onLocationUpdated(
    LocationUpdated event,
    Emitter<LocationState> emit,
  ) {
    emit(LocationAvailable(
      position: event.position,
      address: event.address,
    ));
  }

  Future<void> _onRefreshLocation(
    RefreshLocation event,
    Emitter<LocationState> emit,
  ) async {
    add(const CheckAndRequestPermission());
  }

  void _onLocationPermissionDenied(
    LocationPermissionDeniedEvent event,
    Emitter<LocationState> emit,
  ) {
    emit(const LocationPermissionDenied('Location permission is required to find nearby fields.'));
  }

  Future<void> _onLoadLocationDetails(
    LoadLocationDetails event,
    Emitter<LocationState> emit,
  ) async {
    emit(const LocationLoading());
    final result = await _getLocationDetailsUseCase(event.slug);
    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locationDetails) => emit(LocationDetailsLoaded(locationDetails)),
    );
  }
}