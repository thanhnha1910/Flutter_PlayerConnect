import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/location_details_model.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/auth/getpaymentstatus_usecase.dart';
import '../../../domain/usecases/auth/initiatepayment_usecase.dart';
import '../../../domain/usecases/fetch_venue_details_usecase.dart'; // Add this import

part 'venue_details_event.dart';
part 'venue_details_state.dart';
@injectable
class VenueDetailsBloc extends Bloc<VenueDetailsEvent, VenueDetailsState> {
  final FetchVenueDetailsUseCase fetchVenueDetailsUseCase;

  VenueDetailsBloc({required this.fetchVenueDetailsUseCase})
      : super(VenueDetailsInitial()) {
    on<FetchVenueDetails>((event, emit) async {
      emit(VenueDetailsLoading());
      final result = await fetchVenueDetailsUseCase(event.slug);
      result.fold(
            (failure) => emit(VenueDetailsError(failure.message ?? 'Failed to load venue details')),
            (locationDetails) => emit(VenueDetailsLoaded(locationDetails)),
      );
    });
  }
}