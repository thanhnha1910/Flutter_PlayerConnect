import 'package:injectable/injectable.dart';
import '../../repositories/onboarding_repository.dart';

@lazySingleton
class CheckOnboardingStatusUseCase {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.checkOnboardingStatus();
  }
}