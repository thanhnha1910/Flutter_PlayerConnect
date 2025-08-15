import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class ForgotPasswordUseCase {
  final AuthRepository repository;
  
  ForgotPasswordUseCase(this.repository);
  
  Future<Either<Failure, void>> call(String email) {
    return repository.forgotPassword(email);
  }
}