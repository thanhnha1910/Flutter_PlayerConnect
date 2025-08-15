part of 'venue_details_bloc.dart';

abstract class VenueDetailsEvent extends Equatable {
  const VenueDetailsEvent();

  @override
  List<Object> get props => [];
}

class FetchVenueDetails extends VenueDetailsEvent {
  final String slug;

  const FetchVenueDetails(this.slug);

  @override
  List<Object> get props => [slug];
}
