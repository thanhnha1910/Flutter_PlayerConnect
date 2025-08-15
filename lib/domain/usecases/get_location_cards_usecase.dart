import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/location_card_response.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class GetLocationCardsUseCase {
  final LocationRepository repository;

  GetLocationCardsUseCase(this.repository);

  Future<Either<Failure, List<LocationCardResponse>>> call({
    String? sortBy,
  }) async {
    return await repository.getAllLocationsForCards(
      sortBy: sortBy,
    );
  }
}