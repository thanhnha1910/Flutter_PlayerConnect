import '../../../data/models/onboarding_request_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/models/sport_model.dart';

abstract class OnboardingRepository {
  Future<List<SportModel>> getAllActiveSports();
  Future<List<TagModel>> getTagsBySport(int sportId);
  Future<void> submitOnboarding(OnboardingRequestModel request);
  Future<bool> checkOnboardingStatus();
}