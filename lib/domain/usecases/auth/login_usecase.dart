import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class LoginUseCase {
  final AuthRepository repository;
  
  LoginUseCase(this.repository);
  
  Future<Either<Failure, UserModel>> call(String email, String password) {
  
    
    final result = repository.login(email, password);
    
    return result;
  }
}