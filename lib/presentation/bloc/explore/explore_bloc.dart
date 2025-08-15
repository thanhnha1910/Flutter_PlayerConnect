import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/services/location_permission_service.dart';
import '../../../core/services/geocoding_service.dart';
import '../../../data/models/location_map_model.dart';
import '../../../data/models/location_card_response.dart';
import '../../../data/models/sport_model.dart';
import '../../../domain/usecases/get_locations_usecase.dart';
import '../../../domain/usecases/search_locations_usecase.dart';
import '../../../domain/usecases/get_location_cards_usecase.dart';
import '../../../domain/usecases/get_active_sports_usecase.dart';

// Events
abstract class ExploreEvent extends Equatable {
  const ExploreEvent();

  @override
  List<Object?> get props => [];
}

class LoadInitialData extends ExploreEvent {
  const LoadInitialData();
}

class RequestLocationPermission extends ExploreEvent {
  const RequestLocationPermission();
}

class SearchLocationsInArea extends ExploreEvent {
  final double latitude;
  final double longitude;
  final double radius;
  final String? type;
  final String? category;
  final double? minPrice;
  final double? maxPrice;

  const SearchLocationsInArea({
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.type,
    this.category,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radius,
    type,
    category,
    minPrice,
    maxPrice,
  ];
}

class LoadAllLocations extends ExploreEvent {
  final String? sortBy;

  const LoadAllLocations({this.sortBy});

  @override
  List<Object?> get props => [sortBy];
}

class UpdateMapCamera extends ExploreEvent {
  final double latitude;
  final double longitude;
  final double zoom;

  const UpdateMapCamera({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  @override
  List<Object?> get props => [latitude, longitude, zoom];
}

class ToggleViewMode extends ExploreEvent {
  const ToggleViewMode();
}

class ApplyFilters extends ExploreEvent {
  final String? selectedSport;
  final double? minPrice;
  final double? maxPrice;
  final double? radius;

  const ApplyFilters({
    this.selectedSport,
    this.minPrice,
    this.maxPrice,
    this.radius,
  });

  @override
  List<Object?> get props => [selectedSport, minPrice, maxPrice, radius];
}

class LoadSports extends ExploreEvent {
  const LoadSports();
}

class SearchByText extends ExploreEvent {
  final String searchQuery;

  const SearchByText({required this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class SearchNearbyFields extends ExploreEvent {
  final double? customRadius;

  const SearchNearbyFields({this.customRadius});

  @override
  List<Object?> get props => [customRadius];
}

// States
abstract class ExploreState extends Equatable {
  const ExploreState();

  @override
  List<Object?> get props => [];
}

class ExploreInitial extends ExploreState {
  const ExploreInitial();
}

class ExploreLoading extends ExploreState {
  const ExploreLoading();
}

class LocationPermissionDenied extends ExploreState {
  final String message;

  const LocationPermissionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationPermissionRequired extends ExploreState {
  final String message;

  const LocationPermissionRequired(this.message);

  @override
  List<Object?> get props => [message];
}

class ExploreLoaded extends ExploreState {
  final List<LocationMapModel> mapLocations;
  final List<LocationCardResponse> cardLocations;
  final List<SportModel> sports;
  final Position? userLocation;
  final String? currentAddress;
  final bool isMapView;
  final String? selectedSport;
  final double? minPrice;
  final double? maxPrice;
  final double? searchRadius;
  final bool isGeocodingUpdate;

  const ExploreLoaded({
    required this.mapLocations,
    required this.cardLocations,
    required this.sports,
    this.userLocation,
    this.currentAddress,
    this.isMapView = true,
    this.selectedSport,
    this.minPrice,
    this.maxPrice,
    this.searchRadius,
    this.isGeocodingUpdate = false,
  });

  ExploreLoaded copyWith({
    List<LocationMapModel>? mapLocations,
    List<LocationCardResponse>? cardLocations,
    List<SportModel>? sports,
    Position? userLocation,
    String? currentAddress,
    bool? isMapView,
    String? selectedSport,
    double? minPrice,
    double? maxPrice,
    double? searchRadius,
    bool? isGeocodingUpdate,
  }) {
    return ExploreLoaded(
      mapLocations: mapLocations ?? this.mapLocations,
      cardLocations: cardLocations ?? this.cardLocations,
      sports: sports ?? this.sports,
      userLocation: userLocation ?? this.userLocation,
      currentAddress: currentAddress ?? this.currentAddress,
      isMapView: isMapView ?? this.isMapView,
      selectedSport: selectedSport ?? this.selectedSport,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchRadius: searchRadius ?? this.searchRadius,
      isGeocodingUpdate: isGeocodingUpdate ?? this.isGeocodingUpdate,
    );
  }

  @override
  List<Object?> get props => [
    mapLocations,
    cardLocations,
    sports,
    userLocation,
    currentAddress,
    isMapView,
    selectedSport,
    minPrice,
    maxPrice,
    searchRadius,
    isGeocodingUpdate,
  ];
}

class ExploreError extends ExploreState {
  final String message;

  const ExploreError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@injectable
class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  final GetLocationsUseCase getLocationsUseCase;
  final SearchLocationsUseCase searchLocationsUseCase;
  final GetLocationCardsUseCase getLocationCardsUseCase;
  final GetActiveSportsUseCase getActiveSportsUseCase;
  final LocationPermissionService locationPermissionService;

  // Enhanced caching properties to prevent excessive API calls
  LatLng? _lastSearchedLatLng;
  double? _lastSearchedRadius;
  String? _lastSearchedType;
  String? _lastSearchedCategory;
  double? _lastSearchedMinPrice;
  double? _lastSearchedMaxPrice;
  DateTime? _lastSearchTime;

  // Minimum time between searches (in milliseconds)
  static const int _minSearchInterval = 1000;

  // Minimum distance threshold for new search (in meters)
  static const double _minDistanceThreshold = 500.0;

  ExploreBloc({
    required this.getLocationsUseCase,
    required this.searchLocationsUseCase,
    required this.getLocationCardsUseCase,
    required this.getActiveSportsUseCase,
    required this.locationPermissionService,
  }) : super(const ExploreInitial()) {
    on<LoadInitialData>(_onLoadInitialData);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<SearchLocationsInArea>(_onSearchLocationsInArea);
    on<LoadAllLocations>(_onLoadAllLocations);
    on<UpdateMapCamera>(_onUpdateMapCamera);
    on<ToggleViewMode>(_onToggleViewMode);
    on<ApplyFilters>(_onApplyFilters);
    on<LoadSports>(_onLoadSports);
    on<SearchByText>(_onSearchByText);
    on<SearchNearbyFields>(_onSearchNearbyFields);
  }

  Future<void> _onLoadInitialData(
      LoadInitialData event,
      Emitter<ExploreState> emit,
      ) async {
    emit(const ExploreLoading());

    try {
      // Load initial data concurrently
      final results = await Future.wait([
        getLocationsUseCase(),
        getLocationCardsUseCase(),
        getActiveSportsUseCase(),
      ]);

      final mapLocationsResult = results[0] as Either<Failure, List<LocationMapModel>>;
      final cardLocationsResult = results[1] as Either<Failure, List<LocationCardResponse>>;
      final sportsResult = results[2] as Either<Failure, List<SportModel>>;

      final mapLocations = mapLocationsResult.fold(
        (failure) => <LocationMapModel>[],
        (locations) => locations,
      );

      final cardLocations = cardLocationsResult.fold(
        (failure) => <LocationCardResponse>[],
        (locations) => locations,
      );

      final sports = sportsResult.fold(
        (failure) => <SportModel>[],
        (sportsList) => sportsList,
      );

      // Robust state machine for permission flow
      try {
        // Check if location services are enabled
        final isLocationServiceEnabled = await locationPermissionService.isLocationServiceEnabled();
        if (!isLocationServiceEnabled) {
          emit(ExploreLoaded(
            mapLocations: mapLocations,
            cardLocations: cardLocations,
            sports: sports,
          ));
          emit(const ExploreError('Location services are disabled. Please enable location services in settings.'));
          return;
        }

        // Check current permission status
        final permissionStatus = await Geolocator.checkPermission();

        if (permissionStatus == LocationPermission.denied) {
          // Emit loaded state first with basic data
          emit(ExploreLoaded(
            mapLocations: mapLocations,
            cardLocations: cardLocations,
            sports: sports,
          ));
          // Then emit permission required state
          emit(const LocationPermissionRequired('Please grant location permission to find nearby fields.'));
          return;
        }

        if (permissionStatus == LocationPermission.deniedForever) {
          emit(ExploreLoaded(
            mapLocations: mapLocations,
            cardLocations: cardLocations,
            sports: sports,
          ));
          emit(const ExploreError('Location permission was permanently denied. Please enable it in settings.'));
          return;
        }

        if (permissionStatus == LocationPermission.always || permissionStatus == LocationPermission.whileInUse) {
          // Get user location
          final userLocation = await locationPermissionService.getCurrentLocation();
          String? currentAddress;

          if (userLocation != null) {
            try {
              // Get current address using geocoding
              currentAddress = await GeocodingService.getShortAddress(
                userLocation.latitude,
                userLocation.longitude,
              );
            } catch (e) {
              print('Error getting current address: $e');
              currentAddress = 'Vị trí hiện tại';
            }
          }

          emit(ExploreLoaded(
            mapLocations: mapLocations,
            cardLocations: cardLocations,
            sports: sports,
            userLocation: userLocation,
            currentAddress: currentAddress,
          ));

          // Note: UI will trigger SearchNearbyFields when needed
          // Don't auto-add events here to avoid "Cannot add new events after calling close" error
        }
      } catch (e) {
        print('Location permission error: $e');
        // Emit basic loaded state without location
        emit(ExploreLoaded(
          mapLocations: mapLocations,
          cardLocations: cardLocations,
          sports: sports,
        ));
      }
    } catch (e, stackTrace) {
      print('[BLOC] CRITICAL ERROR caught in LoadInitialData: $e');
      print('[BLOC] StackTrace: $stackTrace');
      final errorMessage = 'Lỗi không mong muốn: ${e.toString()}';
      print('[BLOC] Emitting ExploreError with message: $errorMessage');
      emit(ExploreError(errorMessage));
    }
  }

  Future<void> _onRequestLocationPermission(
      RequestLocationPermission event,
      Emitter<ExploreState> emit,
      ) async {
    try {
      final hasPermission = await locationPermissionService.requestLocationPermission();

      if (!hasPermission) {
        emit(const LocationPermissionDenied(
          'Cần quyền truy cập vị trí để hiển thị sân gần bạn',
        ));
        return;
      }

      final userLocation = await locationPermissionService.getCurrentLocation();

      // Get current address immediately
      String? currentAddress;
      if (userLocation != null) {
        try {
          // Try to get address using geocoding
          currentAddress = await GeocodingService.getShortAddress(
            userLocation.latitude,
            userLocation.longitude,
          );
        } catch (e) {
          print('Error getting current address: $e');
          // Fallback to coordinates display
          currentAddress = 'Lat: ${userLocation.latitude.toStringAsFixed(4)}, Lng: ${userLocation.longitude.toStringAsFixed(4)}';
        }
      }

      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;
        emit(currentState.copyWith(
          userLocation: userLocation,
          currentAddress: currentAddress,
        ));

        // Don't auto-trigger SearchNearbyFields to avoid infinite loop
        // The UI should handle triggering search after permission is granted
        print('[BLOC] Location permission granted and location updated in state');
      }
    } catch (e) {
      print('Location permission error: $e');
      emit(ExploreError('Không thể lấy quyền truy cập vị trí: ${e.toString()}'));
    }
  }

  Future<void> _onSearchLocationsInArea(
      SearchLocationsInArea event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is! ExploreLoaded) return;

    final currentState = state as ExploreLoaded;
    final currentLatLng = LatLng(event.latitude, event.longitude);

    // Enhanced caching logic with time and distance thresholds
    if (_shouldSkipApiCall(currentLatLng, event.radius, event.type, event.category, event.minPrice, event.maxPrice)) {
      print('[BLOC] Skipping API call - within cache threshold');
      return;
    }

    // Check time-based throttling
    final now = DateTime.now();
    if (_lastSearchTime != null &&
        now.difference(_lastSearchTime!).inMilliseconds < _minSearchInterval) {
      print('[BLOC] Skipping API call - too soon since last search');
      return;
    }

    print('[BLOC] Executing SearchLocationsInArea - lat: ${event.latitude}, lng: ${event.longitude}, radius: ${event.radius}');

    // Update search time immediately to prevent duplicate calls
    _lastSearchTime = now;

    // Don't emit loading state for map-triggered searches to avoid UI flicker
    // emit(const ExploreLoading());

    try {
      final result = await searchLocationsUseCase(
        latitude: event.latitude,
        longitude: event.longitude,
        radius: event.radius,
        type: event.type,
        category: event.category,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );

      // Update cache after successful API call
      _updateCache(currentLatLng, event.radius, event.type, event.category, event.minPrice, event.maxPrice);

      result.fold(
            (failure) {
          print('[BLOC] Search failed: ${failure.toString()}');
          // Don't emit error for map searches, just log it
          // emit(ExploreError('Failed to search locations: ${failure.toString()}'));
        },
            (locations) {
          print('[BLOC] Search successful: ${locations.length} locations found');
          // Update cache after successful API call
          _updateCache(currentLatLng, event.radius, event.type, event.category, event.minPrice, event.maxPrice);
          _lastSearchTime = now;
          emit(currentState.copyWith(mapLocations: locations));
        },
      );
    } catch (e) {
      print('[BLOC] Search exception: $e');
      // Don't emit error for map searches, just log it
      // emit(ExploreError('Unexpected error during search: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAllLocations(
      LoadAllLocations event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is! ExploreLoaded) return;

    final currentState = state as ExploreLoaded;

    try {
      final result = await getLocationCardsUseCase(sortBy: event.sortBy);

      result.fold(
            (failure) => emit(ExploreError('Failed to load locations: ${failure.toString()}')),
            (locations) => emit(currentState.copyWith(cardLocations: locations)),
      );
    } catch (e) {
      emit(ExploreError('Unexpected error loading locations: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateMapCamera(
      UpdateMapCamera event,
      Emitter<ExploreState> emit,
      ) async {
    // This can be used to trigger location search when map camera changes
    // For now, we'll just update the state if needed
  }

  Future<void> _onToggleViewMode(
      ToggleViewMode event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is ExploreLoaded) {
      final currentState = state as ExploreLoaded;
      emit(currentState.copyWith(isMapView: !currentState.isMapView));
    }
  }

  Future<void> _onApplyFilters(
      ApplyFilters event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is! ExploreLoaded) return;

    final currentState = state as ExploreLoaded;

    emit(currentState.copyWith(
      selectedSport: event.selectedSport,
      minPrice: event.minPrice,
      maxPrice: event.maxPrice,
      searchRadius: event.radius,
    ));

    // If user location is available, search with filters
    if (currentState.userLocation != null) {
      add(SearchLocationsInArea(
        latitude: currentState.userLocation!.latitude,
        longitude: currentState.userLocation!.longitude,
        radius: event.radius ?? 10.0, // Default 10km radius
        type: event.selectedSport,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      ));
    }
  }

  Future<void> _onLoadSports(
      LoadSports event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is! ExploreLoaded) return;

    final currentState = state as ExploreLoaded;

    try {
      final result = await getActiveSportsUseCase();

      result.fold(
            (failure) => emit(ExploreError('Failed to load sports: ${failure.toString()}')),
            (sports) => emit(currentState.copyWith(sports: sports)),
      );
    } catch (e) {
      emit(ExploreError('Unexpected error loading sports: ${e.toString()}'));
    }
  }

  Future<void> _onSearchByText(
      SearchByText event,
      Emitter<ExploreState> emit,
      ) async {
    if (state is! ExploreLoaded) return;

    final currentState = state as ExploreLoaded;

    if (event.searchQuery.isEmpty) {
      // If search query is empty, reload all locations
      add(const LoadAllLocations());
      return;
    }

    try {
      // Filter locations based on search query
      final filteredLocations = currentState.cardLocations.where((location) {
        return location.locationName.toLowerCase().contains(event.searchQuery.toLowerCase()) ||
            location.address.toLowerCase().contains(event.searchQuery.toLowerCase());
      }).toList();

      emit(currentState.copyWith(cardLocations: filteredLocations));
    } catch (e) {
      emit(ExploreError('Error during search: ${e.toString()}'));
    }
  }

  Future<void> _onSearchNearbyFields(
      SearchNearbyFields event,
      Emitter<ExploreState> emit,
      ) async {
    print('🔍 [EXPLORE_BLOC] ========== SearchNearbyFields Event Started ==========');
    print('🔍 [EXPLORE_BLOC] Event received: ${event.runtimeType}');
    print('🔍 [EXPLORE_BLOC] Custom radius: ${event.customRadius}');
    print('🔍 [EXPLORE_BLOC] Current state: ${state.runtimeType}');
    print('🔍 [EXPLORE_BLOC] State details: $state');

    // Handle different states appropriately
    if (state is ExploreInitial || state is ExploreLoading) {
      print('[BLOC] State is ${state.runtimeType}, waiting for proper initialization');
      return;
    }

    // For LocationPermissionRequired, LocationPermissionDenied, or ExploreError states,
    // we need to first get basic data and then proceed
    if (state is LocationPermissionRequired || state is LocationPermissionDenied || state is ExploreError) {
      print('[BLOC] State is ${state.runtimeType}, loading basic data first');

      try {
        // Load basic data first
        final results = await Future.wait([
          getLocationsUseCase(),
          getLocationCardsUseCase(),
          getActiveSportsUseCase(),
        ]);

        final mapLocationsResult = results[0] as Either<Failure, List<LocationMapModel>>;
        final cardLocationsResult = results[1] as Either<Failure, List<LocationCardResponse>>;
        final sportsResult = results[2] as Either<Failure, List<SportModel>>;

        final mapLocations = mapLocationsResult.fold(
              (failure) => <LocationMapModel>[],
              (locations) => locations,
        );

        final cardLocations = cardLocationsResult.fold(
              (failure) => <LocationCardResponse>[],
              (locations) => locations,
        );

        final sports = sportsResult.fold(
              (failure) => <SportModel>[],
              (sportsList) => sportsList,
        );

        // Emit basic loaded state
        emit(ExploreLoaded(
          mapLocations: mapLocations,
          cardLocations: cardLocations,
          sports: sports,
        ));
      } catch (e) {
        print('[BLOC] Error loading basic data: $e');
        emit(ExploreError('Không thể tải dữ liệu cơ bản: ${e.toString()}'));
        return;
      }
    }

    // Now we should have ExploreLoaded state
    if (state is! ExploreLoaded) {
      print('[BLOC] ERROR: State is still not ExploreLoaded after initialization, cannot proceed');
      return;
    }

    final currentState = state as ExploreLoaded;
    print('[BLOC] Emitting ExploreLoading state');
    emit(const ExploreLoading());

    try {
      print('[BLOC] Starting SearchNearbyFields execution...');
      // First, try to get user location if not available
      Position? userLocation = currentState.userLocation;
      print('[BLOC] Current user location: ${userLocation?.toString() ?? "null"}');

      if (userLocation == null) {
        print('[BLOC] User location is null, requesting permission...');
        final hasPermission = await locationPermissionService.requestLocationPermission();
        print('[BLOC] Location permission granted: $hasPermission');

        if (!hasPermission) {
          print('[BLOC] Location permission denied, emitting LocationPermissionDenied');
          emit(const LocationPermissionDenied(
            'Cần quyền truy cập vị trí để tìm sân gần bạn',
          ));
          return;
        }

        print('[BLOC] Getting current location...');
        userLocation = await locationPermissionService.getCurrentLocation();
        print('[BLOC] Retrieved user location: ${userLocation?.toString() ?? "null"}');
      }

      // Search for nearby locations with specified radius (default 5km)
      final radius = event.customRadius ?? 5.0;
      print('[BLOC] Search radius: ${radius}km');
      print('[BLOC] Search coordinates: lat=${userLocation?.latitude ?? 0.0}, lng=${userLocation?.longitude ?? 0.0}');

      print('[BLOC] Calling searchLocationsUseCase...');
      final result = await searchLocationsUseCase(
        latitude: userLocation?.latitude ?? 0.0,
        longitude: userLocation?.longitude ?? 0.0,
        radius: radius,
      );
      print('[BLOC] searchLocationsUseCase completed');

      result.fold(
            (failure) {
          print('[BLOC] CRITICAL ERROR - Search failure: ${failure.toString()}');
          print('[BLOC] Failure type: ${failure.runtimeType}');
          final errorMessage = 'Không thể tìm sân gần bạn: ${failure.toString()}';
          print('[BLOC] Emitting ExploreError with message: $errorMessage');
          emit(ExploreError(errorMessage));
        },
            (locations) {
          try {
            print('[BLOC] Search successful! Received ${locations.length} locations');

            // Enhanced JSON parsing error handling
            List<LocationMapModel> validLocations = [];

            for (int i = 0; i < locations.length; i++) {
              try {
                final loc = locations[i];
                print('[BLOC] Processing location $i: ID=${loc.locationId}, Name=${loc.name}');

                // Validate required fields with null safety
                if (loc.locationId.isNotEmpty &&
                    loc.latitude != 0.0 &&
                    loc.longitude != 0.0 &&
                    loc.name.isNotEmpty) {
                  validLocations.add(loc);
                  print('[BLOC] Location $i validated successfully');
                } else {
                  print('[BLOC] Location $i failed validation: ID=${loc.locationId}, Lat=${loc.latitude}, Lng=${loc.longitude}, Name=${loc.name}');
                }
              } catch (parseError, stackTrace) {
                print('[BLOC] JSON parsing error for location $i: $parseError');
                print('[BLOC] StackTrace: $stackTrace');
                // Continue processing other locations instead of failing completely
                continue;
              }
            }

            print('[BLOC] Valid locations after filtering and error handling: ${validLocations.length}');

            if (validLocations.isEmpty) {
              print('[BLOC] No valid locations found after JSON parsing, emitting error');
              emit(ExploreError('Không tìm thấy sân nào trong khu vực này hoặc dữ liệu không hợp lệ'));
              return;
            }

            // Sort locations by distance
            final sortedLocations = validLocations.toList();
            sortedLocations.sort((a, b) {
              final distanceA = _calculateDistance(
                userLocation!.latitude,
                userLocation.longitude,
                a.latitude,
                a.longitude,
              );
              final distanceB = _calculateDistance(
                userLocation.latitude,
                userLocation.longitude,
                b.latitude,
                b.longitude,
              );
              return distanceA.compareTo(distanceB);
            });

            // Use coordinates as address for now (geocoding will be handled separately)
            String currentAddress;
            if (userLocation != null) {
              currentAddress = 'Lat: ${userLocation.latitude.toStringAsFixed(4)}, Lng: ${userLocation.longitude.toStringAsFixed(4)}';
              print('[BLOC] Using coordinates as address: $currentAddress');
            } else {
              currentAddress = 'Vị trí không xác định';
            }

            print('[BLOC] Data processed successfully. Emitting ExploreLoaded with ${sortedLocations.length} sorted locations');

            emit(currentState.copyWith(
              mapLocations: sortedLocations,
              userLocation: userLocation,
              searchRadius: radius,
              currentAddress: currentAddress,
              isGeocodingUpdate: false, // Reset geocoding flag
            ));
            print('[BLOC] ExploreLoaded state emitted successfully');

            // Update address with geocoding in background
            if (userLocation != null) {
              _updateAddressInBackground(userLocation);
            }
          } on FormatException catch (formatError, stackTrace) {
            print('[BLOC] CRITICAL ERROR - JSON Format Exception: $formatError');
            print('[BLOC] StackTrace: $stackTrace');
            final errorMessage = 'Lỗi định dạng dữ liệu JSON từ server: ${formatError.toString()}';
            print('[BLOC] Emitting ExploreError with message: $errorMessage');
            emit(ExploreError(errorMessage));
          } on TypeError catch (typeError, stackTrace) {
            print('[BLOC] CRITICAL ERROR - Type Error in JSON parsing: $typeError');
            print('[BLOC] StackTrace: $stackTrace');
            final errorMessage = 'Lỗi kiểu dữ liệu không khớp: ${typeError.toString()}';
            print('[BLOC] Emitting ExploreError with message: $errorMessage');
            emit(ExploreError(errorMessage));
          } catch (parseError, stackTrace) {
            print('[BLOC] CRITICAL ERROR - General parsing error: $parseError');
            print('[BLOC] StackTrace: $stackTrace');
            final errorMessage = 'Lỗi xử lý dữ liệu: ${parseError.toString()}';
            print('[BLOC] Emitting ExploreError with message: $errorMessage');
            emit(ExploreError(errorMessage));
          }
        },
      );
    } catch (e) {
      emit(ExploreError('Lỗi không mong muốn: ${e.toString()}'));
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  // Update address with geocoding in background
  void _updateAddressInBackground(Position userLocation) async {
    try {
      print('[BLOC] Getting current address using geocoding service in background...');
      final currentAddress = await GeocodingService.getShortAddress(
        userLocation.latitude,
        userLocation.longitude,
      );
      print('[BLOC] Current address retrieved in background: $currentAddress');
      print('[BLOC] Final geocoded address: $currentAddress');

      // Only update if we're still in ExploreLoaded state
      if (state is ExploreLoaded) {
        final currentState = state as ExploreLoaded;
        // Add flag to indicate this is a background geocoding update
        emit(currentState.copyWith(
          currentAddress: currentAddress,
          isGeocodingUpdate: true,
        ));

        // Reset the geocoding flag after a short delay to allow UI to process
        Future.delayed(const Duration(milliseconds: 100), () {
          if (state is ExploreLoaded) {
            final latestState = state as ExploreLoaded;
            emit(latestState.copyWith(isGeocodingUpdate: false));
          }
        });
        print('[BLOC] Address updated successfully in background');
      }
    } catch (e) {
      print('[BLOC] Error getting current address in background: $e');
      // Don't emit error for background geocoding failure
    }
  }

  // Helper method to check if we should skip API call due to caching
  bool _shouldSkipApiCall(LatLng currentLatLng, double? radius, String? type, String? category, double? minPrice, double? maxPrice) {
    if (_lastSearchedLatLng == null) return false;

    // Calculate distance between current and last searched location
    final distance = Geolocator.distanceBetween(
      _lastSearchedLatLng!.latitude,
      _lastSearchedLatLng!.longitude,
      currentLatLng.latitude,
      currentLatLng.longitude,
    );

    // Skip if within distance threshold and same search parameters
    return distance < _minDistanceThreshold &&
        _lastSearchedRadius == radius &&
        _lastSearchedType == type &&
        _lastSearchedCategory == category &&
        _lastSearchedMinPrice == minPrice &&
        _lastSearchedMaxPrice == maxPrice;
  }

  // Helper method to update cache after successful API call
  void _updateCache(LatLng latLng, double? radius, String? type, String? category, double? minPrice, double? maxPrice) {
    _lastSearchedLatLng = latLng;
    _lastSearchedRadius = radius;
    _lastSearchedType = type;
    _lastSearchedCategory = category;
    _lastSearchedMinPrice = minPrice;
    _lastSearchedMaxPrice = maxPrice;
  }
}