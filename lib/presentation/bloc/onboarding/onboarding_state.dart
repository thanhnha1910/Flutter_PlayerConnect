part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingRequired extends OnboardingState {}

class SportsLoaded extends OnboardingState {
  final List<SportModel> sports;

  const SportsLoaded({required this.sports});

  @override
  List<Object?> get props => [sports];
}

class TagsLoaded extends OnboardingState {
  final int sportId;
  final List<TagModel> tags;

  const TagsLoaded({required this.sportId, required this.tags});

  @override
  List<Object?> get props => [sportId, tags];
}

class OnboardingInProgress extends OnboardingState {
  final List<SportModel> sports;
  final Map<int, SportProfileModel> sportProfiles;
  final Map<int, List<TagModel>> availableTags;

  const OnboardingInProgress({
    required this.sports,
    required this.sportProfiles,
    required this.availableTags,
  });

  @override
  List<Object?> get props => [sports, sportProfiles, availableTags];
}

class OnboardingSubmitting extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError({required this.message});

  @override
  List<Object?> get props => [message];
}