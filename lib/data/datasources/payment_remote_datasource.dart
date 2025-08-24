import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/payment_model.dart';
import '../models/payment_approval_model.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentApprovalModel> initiatePayment({
    required int payableId,
    required String payableType,
    required int amount,
  });

  Future<PaymentModel> getPaymentDetail(int paymentId);
}

@LazySingleton(as: PaymentRemoteDataSource)
class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final ApiClient apiClient;

  PaymentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaymentApprovalModel> initiatePayment({
    required int payableId,
    required String payableType,
    required int amount,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '${ApiConstants.baseUrl}/api/payment/initiate',
        queryParameters: {
          'payableId': payableId,
          'payableType': payableType,
          'amount': amount,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map ? response.data : {'approvalUrl': response.data};
        return PaymentApprovalModel.fromJson(data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to initiate payment',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/api/payment/initiate'),
        message: e.toString(),
      );
    }
  }

  @override
  Future<PaymentModel> getPaymentDetail(int paymentId) async {
    try {
      final response = await apiClient.dio.get('${ApiConstants.baseUrl}/api/payment/$paymentId');

      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data['data'] ?? response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to load payment detail',
        );
      }
    } catch (e) {
      if (e is DioException) rethrow;
      throw DioException(
        requestOptions: RequestOptions(path: '${ApiConstants.baseUrl}/api/payment/$paymentId'),
        message: e.toString(),
      );
    }
  }
}