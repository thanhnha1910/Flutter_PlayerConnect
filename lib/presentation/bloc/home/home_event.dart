part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadMapData extends HomeEvent {
  const LoadMapData();
}

class SelectLocation extends HomeEvent {
  final LocationMapModel? location;

  const SelectLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class UpdateUserLocation extends HomeEvent {
  final LatLng location;

  const UpdateUserLocation(this.location);

  @override
  List<Object?> get props => [location];
}

class FilterLocationsByDistance extends HomeEvent {
  final double maxDistance;

  const FilterLocationsByDistance(this.maxDistance);

  @override
  List<Object?> get props => [maxDistance];
}

class RequestLocationPermission extends HomeEvent {
  const RequestLocationPermission();
}