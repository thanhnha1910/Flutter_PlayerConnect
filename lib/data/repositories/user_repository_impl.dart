import 'package:injectable/injectable.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';
import '../models/booking_history_model.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  
  UserRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserModel> getUserProfile() async {
    try {
      return await remoteDataSource.getUserProfile();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      return await remoteDataSource.updateUserProfile(updates);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<List<BookingHistoryModel>> getUserBookings() async {
    try {
      return await remoteDataSource.getUserBookings();
    } catch (e) {
      throw Exception('Failed to get user bookings: $e');
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}