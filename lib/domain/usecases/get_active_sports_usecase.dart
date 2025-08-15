import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/sport_model.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class GetActiveSportsUseCase {
  final LocationRepository repository;

  GetActiveSportsUseCase(this.repository);

  Future<Either<Failure, List<SportModel>>> call() async {
    return await repository.getActiveSports();
  }
}