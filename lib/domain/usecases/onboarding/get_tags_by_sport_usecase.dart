import 'package:injectable/injectable.dart';
import '../../repositories/onboarding_repository.dart';
import '../../../data/models/tag_model.dart';

@lazySingleton
class GetTagsBySportUseCase {
  final OnboardingRepository repository;

  GetTagsBySportUseCase(this.repository);

  Future<List<TagModel>> call(int sportId) async {
    return await repository.getTagsBySport(sportId);
  }
}