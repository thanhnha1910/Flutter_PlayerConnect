part of 'venue_details_bloc.dart';

abstract class VenueDetailsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VenueDetailsInitial extends VenueDetailsState {}

class VenueDetailsLoading extends VenueDetailsState {}

class VenueDetailsLoaded extends VenueDetailsState {
  final LocationDetailsModel locationDetails;

  VenueDetailsLoaded(this.locationDetails);

  @override
  List<Object?> get props => [locationDetails];
}

class VenueDetailsError extends VenueDetailsState {
  final String message;

  VenueDetailsError(this.message);

  @override
  List<Object?> get props => [message];
}