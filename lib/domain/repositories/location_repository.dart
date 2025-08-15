import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/location_details_model.dart';
import '../../data/models/location_model.dart';
import '../../data/models/location_map_model.dart';
import '../../data/models/location_card_response.dart';
import '../../data/models/sport_model.dart';
import '../../data/models/booking_model.dart';

abstract class LocationRepository {
  Future<Either<Failure, List<LocationMapModel>>> getLocations();
  Future<Either<Failure, List<LocationMapModel>>> searchLocationsInArea({
    required double latitude,
    required double longitude,
    required double radius,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  });
  Future<Either<Failure, List<LocationCardResponse>>> getAllLocationsForCards({
    String? sortBy,
  });
  Future<Either<Failure, List<SportModel>>> getActiveSports();
  Future<Either<Failure, List<SportModel>>> searchSportsByName(String name);
  Future<Either<Failure, LocationModel>> getLocationById(int id);
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required int fieldId,
    required DateTime date,
  });
  Future<Either<Failure, BookingModel>> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
  Future<Either<Failure, LocationDetailsModel>> getDetails(String slug);
}