part of 'location_bloc.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();

  @override
  List<Object?> get props => [];
}

class CheckAndRequestPermission extends LocationEvent {
  const CheckAndRequestPermission();
}

class LocationUpdated extends LocationEvent {
  final Position position;
  final String? address;

  const LocationUpdated({
    required this.position,
    this.address,
  });

  @override
  List<Object?> get props => [position, address];
}

class RefreshLocation extends LocationEvent {
  const RefreshLocation();
}

class LocationPermissionDeniedEvent extends LocationEvent {
  const LocationPermissionDeniedEvent();
}

class LoadLocationDetails extends LocationEvent {
  final String slug;

  const LoadLocationDetails(this.slug);

  @override
  List<Object?> get props => [slug];
}