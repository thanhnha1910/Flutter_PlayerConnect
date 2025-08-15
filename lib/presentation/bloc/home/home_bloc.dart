import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../data/models/location_map_model.dart';
import '../../../domain/usecases/get_locations_usecase.dart';
import '../../../core/utils/location_utils.dart';
import '../../../core/services/location_permission_service.dart';

part 'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetLocationsUseCase getLocationsUseCase;
  final LocationPermissionService _locationPermissionService = LocationPermissionService();

  HomeBloc({
    required this.getLocationsUseCase,
  }) : super(HomeInitial()) {
    on<LoadMapData>(_onLoadMapData);
    on<SelectLocation>(_onSelectLocation);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<FilterLocationsByDistance>(_onFilterLocationsByDistance);
    on<RequestLocationPermission>(_onRequestLocationPermission);
  }

  Future<void> _onLoadMapData(
    LoadMapData event,
    Emitter<HomeState> emit,
  ) async {
    print('=== HomeBloc: LoadMapData event received ===');
    emit(HomeLoading());
    
    try {
      // Check location permission first
      bool hasPermission = await _locationPermissionService.hasLocationPermission();
      bool isLocationServiceEnabled = await _locationPermissionService.isLocationServiceEnabled();
      
      if (!isLocationServiceEnabled) {
        emit(LocationServiceDisabled('Dịch vụ vị trí đã bị tắt. Vui lòng bật dịch vụ vị trí trong cài đặt.'));
        return;
      }
      
      if (!hasPermission) {
        emit(LocationPermissionRequired('Cần quyền truy cập vị trí để hiển thị sân gần bạn'));
        return;
      }
      
      // Get user's current location
      Position? userPosition;
      try {
        print('HomeBloc: Getting user location...');
        userPosition = await _locationPermissionService.getCurrentLocation();
        if (userPosition == null) {
          throw Exception('Không thể lấy vị trí hiện tại');
        }
        print('HomeBloc: User location obtained: ${userPosition.latitude}, ${userPosition.longitude}');
      } catch (e) {
        print('HomeBloc: Failed to get location: $e');
        emit(HomeError('Không thể lấy vị trí hiện tại. Vui lòng thử lại.'));
        return;
      }

      // Get locations from API
      print('HomeBloc: Calling getLocationsUseCase...');
      final result = await getLocationsUseCase.call();
      print('HomeBloc: getLocationsUseCase completed, processing result...');
      
      result.fold(
        (failure) {
          print('HomeBloc: API call failed with error: ${failure.message}');
          print('HomeBloc: Emitting HomeError state');
          emit(HomeError(failure.message));
        },
        (locations) {
          print('HomeBloc: API call successful, received ${locations.length} locations');
          print('HomeBloc: First location: ${locations.isNotEmpty ? locations.first.name : "No locations"}');
          
          // Calculate distance for each location
          final locationsWithDistance = locations.map((location) {
            final distance = LocationUtils.calculateDistance(
              userPosition!.latitude,
              userPosition.longitude,
              location.latitude,
              location.longitude,
            );
            return location.copyWith(distance: distance);
          }).toList();

          // Sort by distance
          locationsWithDistance.sort((a, b) => 
            (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));

          print('HomeBloc: Processed ${locationsWithDistance.length} locations with distances');
          print('HomeBloc: Emitting HomeMapReady state');
          emit(HomeMapReady(
            locations: locationsWithDistance,
            userLocation: LatLng(userPosition!.latitude, userPosition.longitude),
            selectedLocation: null,
          ));
        },
      );
    } catch (e) {
      print('HomeBloc: Unexpected error in _onLoadMapData: $e');
      print('HomeBloc: Emitting HomeError state with generic message');
      emit(HomeError('Đã xảy ra lỗi khi tải dữ liệu: ${e.toString()}'));
    }
  }

  void _onSelectLocation(
    SelectLocation event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeMapReady) {
      final currentState = state as HomeMapReady;
      if (event.location == null) {
        emit(currentState.copyWith(clearSelectedLocation: true));
      } else {
        emit(currentState.copyWith(selectedLocation: event.location));
      }
    }
  }

  void _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeMapReady) {
      final currentState = state as HomeMapReady;
      emit(currentState.copyWith(userLocation: event.location));
    }
  }

  void _onFilterLocationsByDistance(
    FilterLocationsByDistance event,
    Emitter<HomeState> emit,
  ) {
    if (state is HomeMapReady) {
      final currentState = state as HomeMapReady;
      final filteredLocations = currentState.locations
          .where((location) => (location.distance ?? 0) <= event.maxDistance)
          .toList();
      
      emit(currentState.copyWith(locations: filteredLocations));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<HomeState> emit,
  ) async {
    try {
      bool hasPermission = await _locationPermissionService.requestLocationPermission();
      
      if (hasPermission) {
        // Permission granted, reload map data
        add(const LoadMapData());
      } else {
        emit(const HomeError('Quyền truy cập vị trí bị từ chối. Vui lòng cấp quyền trong cài đặt ứng dụng.'));
      }
    } catch (e) {
      emit(HomeError('Lỗi khi yêu cầu quyền truy cập vị trí: ${e.toString()}'));
    }
  }
}