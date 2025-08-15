import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/core/error/failures.dart';
import 'package:player_connect/data/models/location_details_model.dart';
import 'package:player_connect/domain/repositories/location_repository.dart';

@lazySingleton
class GetVenueDetailsUseCase {
  final LocationRepository repository;

  GetVenueDetailsUseCase(this.repository);

  Future<Either<Failure, LocationDetailsModel>> call(String slug) async {
    return await repository.getDetails(slug);
  }
}
