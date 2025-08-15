import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/location_map_model.dart';
import '../repositories/location_repository.dart';

@lazySingleton
class SearchLocationsUseCase {
  final LocationRepository repository;

  SearchLocationsUseCase(this.repository);

  Future<Either<Failure, List<LocationMapModel>>> call({
    required double latitude,
    required double longitude,
    required double radius,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await repository.searchLocationsInArea(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      type: type,
      category: category,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}