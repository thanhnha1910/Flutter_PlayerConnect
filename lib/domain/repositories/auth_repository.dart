import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/user_model.dart';
import '../../data/models/auth_request_models.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(RegisterRequest request);
  Future<Either<Failure, UserModel>> loginWithGoogle();
  Future<Either<Failure, void>> forgotPassword(String email);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel?>> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<Either<Failure, void>> refreshToken();
}