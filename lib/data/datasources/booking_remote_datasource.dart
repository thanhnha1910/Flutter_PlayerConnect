import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../models/booking_model.dart';
import '../models/booking_receipt_model.dart';
import '../models/booking_request_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';

abstract class BookingRemoteDataSource {
  Future<BookingResponseModel> createBooking(BookingRequestModel request);
  // Future<BookingResponseModel> confirmPayment(String bookingId, PayPalPaymentModel payment); // NOT USED - PayPal uses callback mechanism
  Future<dynamic> getBookingDetails(String bookingId);
  Future<List<BookingModel>> getUserBookings();
  Future<void> cancelBooking(String bookingId);
}

@LazySingleton(as: BookingRemoteDataSource)
class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final ApiClient _apiClient;

  BookingRemoteDataSourceImpl(this._apiClient);

  @override
  Future<BookingResponseModel> createBooking(BookingRequestModel request) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConstants.baseUrl}/booking',
        data: request.toJson(),
        queryParameters: {
          'clientType': 'flutter',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return BookingResponseModel.fromJson(response.data);
      } else {
        throw ServerException(
          'Failed to create booking: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error: $e',
      );
    }
  }

  // @override
  // Future<BookingResponseModel> confirmPayment(
  //   String bookingId,
  //   PayPalPaymentModel payment,
  // ) async {
  //   // NOT USED - PayPal uses callback mechanism via /payment-callback
  //   throw UnimplementedError('PayPal uses callback mechanism, this method is not used');
  // }

  @override
  Future<dynamic> getBookingDetails(String bookingId) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.baseUrl}/booking/receipt/$bookingId',
      );

      if (response.statusCode == 200) {
        // Handle response structure from /booking/receipt/ endpoint
        final data = response.data;
        
        // Check if it's a batch booking response
        if (data['isBatch'] == true && data['bookings'] != null) {
          return BatchBookingReceiptModel.fromJson(data);
        } else if (data['booking'] != null) {
          // Single booking response
          return BookingReceiptModel.fromJson(data['booking']);
        }
        
        // Fallback: try to parse data directly as single booking
        return BookingReceiptModel.fromJson(data);
      } else {
        throw ServerException(
          'Failed to get booking details: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error: $e',
      );
    }
  }

  @override
  Future<List<BookingModel>> getUserBookings() async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConstants.baseUrl}/booking/history',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => BookingModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          'Failed to get user bookings: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error: $e',
      );
    }
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConstants.baseUrl}/booking/$bookingId',
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to cancel booking: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      throw ServerException(
        e.message ?? 'Network error occurred',
      );
    } catch (e) {
      throw ServerException(
        'Unexpected error: $e',
      );
    }
  }
}