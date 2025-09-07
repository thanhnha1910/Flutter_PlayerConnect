import 'package:injectable/injectable.dart';
import '../../data/models/sport_model.dart';
import '../repositories/onboarding_repository.dart';

@lazySingleton
class GetActiveSportsUseCase {
  final OnboardingRepository repository;

  GetActiveSportsUseCase(this.repository);

  Future<List<SportModel>> call() async {
    return await repository.getAllActiveSports();
  }
}