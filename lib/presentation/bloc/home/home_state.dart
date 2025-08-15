part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeMapReady extends HomeState {
  final List<LocationMapModel> locations;
  final LatLng userLocation;
  final LocationMapModel? selectedLocation;

  const HomeMapReady({
    required this.locations,
    required this.userLocation,
    this.selectedLocation,
  });

  HomeMapReady copyWith({
    List<LocationMapModel>? locations,
    LatLng? userLocation,
    LocationMapModel? selectedLocation,
    bool clearSelectedLocation = false,
  }) {
    return HomeMapReady(
      locations: locations ?? this.locations,
      userLocation: userLocation ?? this.userLocation,
      selectedLocation: clearSelectedLocation ? null : (selectedLocation ?? this.selectedLocation),
    );
  }

  @override
  List<Object?> get props => [locations, userLocation, selectedLocation];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationPermissionRequired extends HomeState {
  final String message;

  const LocationPermissionRequired(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationServiceDisabled extends HomeState {
  final String message;

  const LocationServiceDisabled(this.message);

  @override
  List<Object?> get props => [message];
}