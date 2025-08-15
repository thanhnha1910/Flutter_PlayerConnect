import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/auth_request_models.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class RegisterUseCase {
  final AuthRepository repository;
  
  RegisterUseCase(this.repository);
  
  Future<Either<Failure, UserModel>> call(RegisterRequest request) {
    return repository.register(request);
  }
}