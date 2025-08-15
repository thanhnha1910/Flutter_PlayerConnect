import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/data/models/location_details_model.dart';
import 'package:player_connect/domain/usecases/get_venue_details_usecase.dart';

part 'venue_details_event.dart';
part 'venue_details_state.dart';

@injectable
class VenueDetailsBloc extends Bloc<VenueDetailsEvent, VenueDetailsState> {
  final GetVenueDetailsUseCase getVenueDetailsUseCase;

  VenueDetailsBloc(this.getVenueDetailsUseCase) : super(VenueDetailsInitial()) {
    on<FetchVenueDetails>((event, emit) async {
      emit(VenueDetailsLoading());
      print("Making a request with slug: ${event.slug}");
      final failureOrDetails = await getVenueDetailsUseCase(event.slug);
      failureOrDetails.fold(
        (failure) => emit(VenueDetailsError("Failed to fetch venue details")),
        (details) => emit(VenueDetailsLoaded(details)),
      );
    });
  }
}
