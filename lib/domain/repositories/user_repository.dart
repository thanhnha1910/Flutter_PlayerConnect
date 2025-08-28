import '../../data/models/user_model.dart';
import '../../data/models/booking_history_model.dart';

abstract class UserRepository {
  Future<UserModel> getUserProfile();
  Future<UserModel> updateUserProfile(Map<String, dynamic> updates);
  Future<List<BookingHistoryModel>> getUserBookings();
  Future<void> changePassword(String currentPassword, String newPassword);
}