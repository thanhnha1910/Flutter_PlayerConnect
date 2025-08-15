part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationAvailable extends LocationState {
  final Position position;
  final String? address;

  const LocationAvailable({
    required this.position,
    this.address,
  });

  @override
  List<Object?> get props => [position, address];
}

class LocationPermissionDenied extends LocationState {
  final String message;

  const LocationPermissionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationServiceDisabled extends LocationState {
  final String message;

  const LocationServiceDisabled(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object?> get props => [message];
}

class LocationDetailsLoaded extends LocationState {
  final LocationDetailsModel locationDetails;

  const LocationDetailsLoaded(this.locationDetails);

  @override
  List<Object?> get props => [locationDetails];
}