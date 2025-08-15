import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class GoogleSignInUseCase {
  final AuthRepository repository;
  
  GoogleSignInUseCase(this.repository);
  
  Future<Either<Failure, UserModel>> call() {
    return repository.loginWithGoogle();
  }
}