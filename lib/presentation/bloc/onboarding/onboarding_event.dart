part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSports extends OnboardingEvent {
  const LoadSports();
}

class LoadTagsForSport extends OnboardingEvent {
  final int sportId;

  const LoadTagsForSport({required this.sportId});

  @override
  List<Object?> get props => [sportId];
}

class UpdateSportProfile extends OnboardingEvent {
  final SportProfileModel sportProfile;

  const UpdateSportProfile({required this.sportProfile});

  @override
  List<Object?> get props => [sportProfile];
}

class SubmitOnboarding extends OnboardingEvent {
  final OnboardingRequestModel request;

  const SubmitOnboarding({required this.request});

  @override
  List<Object?> get props => [request];
}

class CheckOnboardingStatus extends OnboardingEvent {
  const CheckOnboardingStatus();
}

class AddSportProfile extends OnboardingEvent {
  final SportModel sport;

  const AddSportProfile({required this.sport});

  @override
  List<Object?> get props => [sport];
}

class RemoveSportProfile extends OnboardingEvent {
  final int sportId;

  const RemoveSportProfile({required this.sportId});

  @override
  List<Object?> get props => [sportId];
}

class LoadMultipleTags extends OnboardingEvent {
  final List<int> sportIds;

  const LoadMultipleTags({required this.sportIds});

  @override
  List<Object?> get props => [sportIds];
}

class InitializeOnboarding extends OnboardingEvent {
  final List<SportModel> selectedSports;

  const InitializeOnboarding({required this.selectedSports});

  @override
  List<Object?> get props => [selectedSports];
}