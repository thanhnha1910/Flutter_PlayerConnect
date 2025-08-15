import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../repositories/auth_repository.dart';

@lazySingleton
class LogoutUseCase {
  final AuthRepository repository;
  
  LogoutUseCase(this.repository);
  
  Future<Either<Failure, void>> call() {
    return repository.logout();
  }
}