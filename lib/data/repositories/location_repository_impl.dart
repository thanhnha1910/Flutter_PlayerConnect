import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:player_connect/data/models/location_details_model.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/location_repository.dart';
import '../models/location_model.dart';
import '../models/location_map_model.dart';
import '../models/location_card_response.dart';
import '../models/sport_model.dart';
import '../models/booking_model.dart';
import '../datasources/location_remote_datasource.dart';

@LazySingleton(as: LocationRepository)
class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;

  LocationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<LocationMapModel>>> getLocations() async {
    try {
      print('Repository: Calling remoteDataSource.getLocations()...');
      final locations = await remoteDataSource.getLocations();
      print('Repository: Successfully received ${locations.length} locations');
      return Right(locations);
    } on DioException catch (e) {
      print('Repository: DioException caught: ${e.type}');
      print('Repository: Error message: ${e.message}');
      print('Repository: Response status: ${e.response?.statusCode}');
      print('Repository: Response data: ${e.response?.data}');
      final errorMessage = _mapDioErrorToMessage(e);
      print('Repository: Mapped error message: $errorMessage');
      return Left(ServerFailure(errorMessage));
    } catch (e) {
      print('Repository: Unexpected error caught: $e');
      print('Repository: Error type: ${e.runtimeType}');
      return Left(
        ServerFailure('Đã xảy ra lỗi không xác định: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<LocationMapModel>>> searchLocationsInArea({
    required double latitude,
    required double longitude,
    required double radius,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    print(
      '[Repository] searchLocationsInArea called with lat=$latitude, lng=$longitude, radius=$radius',
    );
    try {
      print('[Repository] Calling remoteDataSource.searchLocationsInArea...');
      final locations = await remoteDataSource.searchLocationsInArea(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        type: type,
        category: category,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );
      print(
        '[Repository] Successfully received ${locations.length} locations from data source',
      );
      return Right(locations);
    } on DioException catch (e) {
      print('[Repository] DioException caught: ${e.message}');
      print('[Repository] DioException type: ${e.type}');
      print('[Repository] DioException response: ${e.response?.data}');
      print('[Repository] Error type: ${e.runtimeType}');
      final errorMessage = _mapDioErrorToMessage(e);
      print('[Repository] Mapped error message: $errorMessage');
      return Left(ServerFailure(errorMessage));
    } catch (e, stackTrace) {
      print('[Repository] Unexpected error caught: $e');
      print('[Repository] Error type: ${e.runtimeType}');
      print('[Repository] StackTrace: $stackTrace');
      return Left(
        ServerFailure('Đã xảy ra lỗi không xác định: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<LocationCardResponse>>> getAllLocationsForCards({
    String? sortBy,
  }) async {
    try {
      final locations = await remoteDataSource.getAllLocationsForCards(
        sortBy: sortBy,
      );
      return Right(locations);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<SportModel>>> getActiveSports() async {
    try {
      final sports = await remoteDataSource.getActiveSports();
      return Right(sports);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<SportModel>>> searchSportsByName(
    String name,
  ) async {
    try {
      final sports = await remoteDataSource.searchSportsByName(name);
      return Right(sports);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, LocationModel>> getLocationById(int id) async {
    try {
      final location = await remoteDataSource.getLocationById(id);
      return Right(location);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, List<TimeSlot>>> getAvailableTimeSlots({
    required int fieldId,
    required DateTime date,
  }) async {
    try {
      final timeSlots = await remoteDataSource.getAvailableTimeSlots(
        fieldId: fieldId,
        date: date,
      );
      return Right(timeSlots);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  @override
  Future<Either<Failure, BookingModel>> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final booking = await remoteDataSource.createBooking(
        fieldId: fieldId,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );
      return Right(booking);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }

  String _mapDioErrorToMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Kết nối mạng bị gián đoạn';
      case DioExceptionType.badResponse:
        if (error.response?.statusCode == 401) {
          return 'Phiên đăng nhập đã hết hạn';
        } else if (error.response?.statusCode == 404) {
          return 'Không tìm thấy dữ liệu';
        } else if (error.response?.statusCode == 500) {
          return 'Lỗi máy chủ';
        }
        return 'Đã xảy ra lỗi: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Yêu cầu đã bị hủy';
      case DioExceptionType.connectionError:
        return 'Không thể kết nối đến máy chủ';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }

  @override
  Future<Either<Failure, LocationDetailsModel>> getDetails(String slug) async {
    try {
      final details = await remoteDataSource.getDetails(slug);
      return Right(details);
    } on DioException catch (e) {
      return Left(ServerFailure(_mapDioErrorToMessage(e)));
    } catch (e) {
      return Left(ServerFailure('Đã xảy ra lỗi không xác định'));
    }
  }
}
