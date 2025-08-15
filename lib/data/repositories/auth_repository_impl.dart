import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import '../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../models/auth_request_models.dart';
import '../datasources/auth_remote_datasource.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;
  
  AuthRepositoryImpl(this.remoteDataSource, this.secureStorage);
  
  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
 
    try {
    
      final result = await remoteDataSource.login(email, password);
      
      await secureStorage.saveToken(result.token);
      await secureStorage.saveRefreshToken(result.refreshToken);
      await secureStorage.saveUserData(
        userId: result.id.toString(),
        email: result.email,
        name: result.fullName,
      );
      
    
      return Right(result.toUser());
    } catch (e) {
    
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserModel>> register(RegisterRequest request) async {
    try {
      final result = await remoteDataSource.register(request);
      return Right(result.toUser());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserModel>> loginWithGoogle() async {
    try {
      final result = await remoteDataSource.loginWithGoogle();
      
      // Save tokens and user data
      await secureStorage.saveToken(result.token);
      await secureStorage.saveRefreshToken(result.refreshToken);
      await secureStorage.saveUserData(
        userId: result.id.toString(),
        email: result.email,
        name: result.fullName,
      );
      
      return Right(result.toUser());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final userData = await secureStorage.getUserData();
      if (userData['userId'] != null) {
        return Right(UserModel(
          id: int.parse(userData['userId']!),
          username: userData['name'] ?? '',
          email: userData['email'] ?? '',
          fullName: userData['name'] ?? '',
          roles: [],
          status: 'ACTIVE',
          hasCompletedProfile: true,
        ));
      }
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
  
  @override
  Future<bool> isLoggedIn() async {
    return await secureStorage.hasToken();
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return Left(AuthFailure('No refresh token available'));
      }

      final result = await remoteDataSource.refreshToken(refreshToken);

      await secureStorage.saveToken(result.token);
      await secureStorage.saveRefreshToken(result.refreshToken);

      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}