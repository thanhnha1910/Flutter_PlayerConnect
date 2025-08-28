import 'package:dio/dio.dart';
import '../models/location_details_model.dart';
import '../models/location_model.dart';
import '../models/location_map_model.dart';
import '../models/location_card_response.dart';
import '../models/sport_model.dart';
import '../models/booking_model.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';

import 'package:injectable/injectable.dart';

abstract class LocationRemoteDataSource {
  Future<List<LocationMapModel>> getLocations();
  Future<List<LocationMapModel>> searchLocationsInArea({
    required double latitude,
    required double longitude,
    required double radius,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  });
  Future<List<LocationCardResponse>> getAllLocationsForCards({
    String? sortBy,
  });
  Future<List<SportModel>> getActiveSports();
  Future<List<SportModel>> searchSportsByName(String name);
  Future<LocationModel> getLocationById(int id);
  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int fieldId,
    required DateTime date,
  });
  Future<BookingModel> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  });
  Future<LocationDetailsModel> getDetails(String slug);
}

@LazySingleton(as: LocationRemoteDataSource)
class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient apiClient;

  LocationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<LocationMapModel>> getLocations() async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/locations/map-data');
      
      print('--- RAW API RESPONSE ---');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('Response Data: ${response.data}');
      print('--- END RAW API RESPONSE ---');
      
      if (response.statusCode == 200) {
        // Fix: API returns array directly, not wrapped in 'data' field
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        print('Parsed data length: ${data.length}');
        return data.map((json) => LocationMapModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load locations',
        );
      }
    } catch (e) {
      print('Error in getLocations: $e');
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/locations/map-data'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<LocationMapModel>> searchLocationsInArea({
    required double latitude,
    required double longitude,
    required double radius,
    String? type,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      };
      
      if (type != null) queryParams['type'] = type;
      if (category != null) queryParams['category'] = category;
      if (minPrice != null) queryParams['minPrice'] = minPrice;
      if (maxPrice != null) queryParams['maxPrice'] = maxPrice;
      
      final url = '${ApiConstants.baseUrl}/locations/map-search';
      print('[DataSource] Making GET request to: $url');
      print('[DataSource] Query parameters: $queryParams');
      
      final response = await apiClient.dio.get(
        url,
        queryParameters: queryParams,
      );
      
      print('[DataSource] Response received - Status Code: ${response.statusCode}');
      print('[DataSource] Response Headers: ${response.headers}');
      print('[DataSource] Response Data Type: ${response.data.runtimeType}');
      print('[DataSource] Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
          print('[DataSource] Response is a List with ${data.length} items');
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
          print('[DataSource] Response is a Map with data field containing ${data.length} items');
        } else {
          print('[DataSource] ERROR: Unexpected response format: ${response.data.runtimeType}');
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        print('[DataSource] Converting ${data.length} items to LocationMapModel objects');
        final locations = data.map((json) => LocationMapModel.fromJson(json)).toList();
        print('[DataSource] Successfully converted to ${locations.length} LocationMapModel objects');
        return locations;
      } else {
        print('[DataSource] ERROR: Non-200 status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search locations',
        );
      }
    } on DioException catch (e) {
      
      rethrow; // Re-throw the error so the repository and BLoC can handle it
    } catch (e, stackTrace) {
      
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/locations/map-search'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<LocationCardResponse>> getAllLocationsForCards({
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      
      final response = await apiClient.dio.get(
        '${ApiConstants.baseUrl}/locations',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        return data.map((json) => LocationCardResponse.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load location cards',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/locations'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<SportModel>> getActiveSports() async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/sports/active');
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        return data.map((json) => SportModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load sports',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/sports/active'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<SportModel>> searchSportsByName(String name) async {
    try {
      final response = await apiClient.dio.get(
        '${ApiConstants.baseUrl}/sports/search',
        queryParameters: {'name': name},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data;
        if (response.data is List) {
          data = response.data as List<dynamic>;
        } else if (response.data is Map && response.data['data'] != null) {
          data = response.data['data'] as List<dynamic>;
        } else {
          throw Exception('Unexpected response format: ${response.data.runtimeType}');
        }
        
        return data.map((json) => SportModel.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to search sports',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/sports/search'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<LocationModel> getLocationById(int id) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/locations/$id');
      
      if (response.statusCode == 200) {
        return LocationModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load location',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/locations/$id'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<TimeSlot>> getAvailableTimeSlots({
    required int fieldId,
    required DateTime date,
  }) async {
    try {
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await apiClient.dio.get(
        '${ApiConstants.baseUrl}/fields/$fieldId/bookings',
        queryParameters: {'date': dateString},
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((json) => TimeSlot.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load time slots',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/fields/$fieldId/bookings'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<BookingModel> createBooking({
    required int fieldId,
    required DateTime startTime,
    required DateTime endTime,
    String? notes,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.baseUrl}/bookings',
        data: {
          'fieldId': fieldId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
          if (notes != null) 'notes': notes,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to create booking',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/bookings'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<LocationDetailsModel> getDetails(String slug) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/locations/$slug');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LocationDetailsModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch venue details',
        );
      }
    } catch (e) {
      if (e is DioException) {
        rethrow;
      }
      throw DioException(
        requestOptions: RequestOptions(
            path: '${ApiConstants.baseUrl}/locations/$slug'),
        message: e.toString(),
      );
    }
  }
}