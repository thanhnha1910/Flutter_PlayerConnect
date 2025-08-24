import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../datasources/venue_remote_datasource.dart';
import '../models/location_details_model.dart';
import '../../domain/repositories/venue_repository.dart';

@LazySingleton(as: VenueRepository)
class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDataSource remoteDataSource;

  VenueRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, LocationDetailsModel>> getVenueDetails(String slug) async {
    try {
      final model = await remoteDataSource.getVenueDetails(slug);
      return Right(model);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}