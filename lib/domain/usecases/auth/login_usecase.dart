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
    print('=== UseCase: Executing LoginUseCase ===');
    print('UseCase: Email: $email');
    print('UseCase: Password length: ${password.length}');
    print('UseCase: Calling repository.login()...');
    
    final result = repository.login(email, password);
    print('UseCase: Repository call completed, returning result');
    
    return result;
  }
}