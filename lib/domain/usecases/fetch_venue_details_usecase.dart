import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../data/models/location_details_model.dart';
import '../../domain/repositories/venue_repository.dart';

class FetchVenueDetailsUseCase {
  final VenueRepository repository;

  FetchVenueDetailsUseCase(this.repository);

  Future<Either<Failure, LocationDetailsModel>> call(String slug) async {
    return await repository.getVenueDetails(slug);
  }
}