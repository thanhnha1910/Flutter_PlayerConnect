import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/location_details_model.dart';

abstract class VenueRepository {
  Future<Either<Failure, LocationDetailsModel>> getVenueDetails(String slug);
}