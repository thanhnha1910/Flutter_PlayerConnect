import 'package:injectable/injectable.dart';
import '../../repositories/onboarding_repository.dart';
import '../../../data/models/onboarding_request_model.dart';

@lazySingleton
class SubmitOnboardingUseCase {
  final OnboardingRepository repository;

  SubmitOnboardingUseCase(this.repository);

  Future<void> call(OnboardingRequestModel params) async {
    return await repository.submitOnboarding(params);
  }
}