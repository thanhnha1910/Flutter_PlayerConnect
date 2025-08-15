import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/location_map_model.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class GetLocationsUseCase {
  final LocationRepository repository;

  GetLocationsUseCase(this.repository);

  Future<Either<Failure, List<LocationMapModel>>> call() async {
    return await repository.getLocations();
  }
}