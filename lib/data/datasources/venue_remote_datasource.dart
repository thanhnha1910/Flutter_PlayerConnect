import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/location_details_model.dart';

abstract class VenueRemoteDataSource {
  Future<LocationDetailsModel> getVenueDetails(String slug);
}

@LazySingleton(as: VenueRemoteDataSource)
class VenueRemoteDataSourceImpl implements VenueRemoteDataSource {
  final ApiClient apiClient;

  VenueRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<LocationDetailsModel> getVenueDetails(String slug) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/api/locations/$slug');
      if (response.statusCode == 200) {
        return LocationDetailsModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load venue details',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/api/locations/$slug'),
        message: e.toString(),
      );
    }
  }
}