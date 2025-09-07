import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/sport_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/models/sport_profile_model.dart';
import '../../../data/models/onboarding_request_model.dart';
import '../../../domain/usecases/onboarding/get_tags_by_sport_usecase.dart';
import '../../../domain/usecases/onboarding/submit_onboarding_usecase.dart';
import '../../../domain/usecases/onboarding/check_onboarding_status_usecase.dart';
import '../../../domain/usecases/get_active_sports_usecase.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

@injectable
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final GetActiveSportsUseCase getActiveSportsUseCase;
  final GetTagsBySportUseCase getTagsBySportUseCase;
  final SubmitOnboardingUseCase submitOnboardingUseCase;
  final CheckOnboardingStatusUseCase checkOnboardingStatusUseCase;

  OnboardingBloc({
    required this.getActiveSportsUseCase,
    required this.getTagsBySportUseCase,
    required this.submitOnboardingUseCase,
    required this.checkOnboardingStatusUseCase,
  }) : super(OnboardingInitial()) {
    on<LoadSports>(_onLoadSports);
    on<LoadTagsForSport>(_onLoadTagsForSport);
    on<UpdateSportProfile>(_onUpdateSportProfile);
    on<SubmitOnboarding>(_onSubmitOnboarding);
    on<CheckOnboardingStatus>(_onCheckOnboardingStatus);
    on<AddSportProfile>(_onAddSportProfile);
    on<RemoveSportProfile>(_onRemoveSportProfile);
    on<LoadMultipleTags>(_onLoadMultipleTags);
    on<InitializeOnboarding>(_onInitializeOnboarding);
  }

  Future<void> _onLoadSports(LoadSports event, Emitter<OnboardingState> emit) async {
    try {
      emit(OnboardingLoading());
      final sports = await getActiveSportsUseCase.call();
      emit(SportsLoaded(sports: sports));
    } catch (e) {
      emit(OnboardingError(message: e.toString()));
    }
  }

  Future<void> _onLoadTagsForSport(LoadTagsForSport event, Emitter<OnboardingState> emit) async {
    try {
      final tags = await getTagsBySportUseCase.call(event.sportId);
      emit(TagsLoaded(sportId: event.sportId, tags: tags));
    } catch (e) {
      emit(OnboardingError(message: 'Failed to load tags: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateSportProfile(UpdateSportProfile event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final updatedProfiles = Map<int, SportProfileModel>.from(currentState.sportProfiles);
      updatedProfiles[event.sportProfile.sportId] = event.sportProfile;
      
      emit(OnboardingInProgress(
        sports: currentState.sports,
        sportProfiles: updatedProfiles,
        availableTags: currentState.availableTags,
      ));
    }
  }

  Future<void> _onSubmitOnboarding(SubmitOnboarding event, Emitter<OnboardingState> emit) async {
    emit(OnboardingSubmitting());
    try {
      await submitOnboardingUseCase.call(event.request);
      emit(OnboardingCompleted());
    } catch (e) {
      emit(OnboardingError(message: 'Failed to submit onboarding: ${e.toString()}'));
    }
  }

  Future<void> _onCheckOnboardingStatus(CheckOnboardingStatus event, Emitter<OnboardingState> emit) async {
    try {
      final isCompleted = await checkOnboardingStatusUseCase.call();
      if (isCompleted) {
        emit(OnboardingCompleted());
      } else {
        emit(OnboardingRequired());
      }
    } catch (e) {
      emit(OnboardingError(message: 'Failed to check onboarding status: ${e.toString()}'));
    }
  }

  Future<void> _onInitializeOnboarding(InitializeOnboarding event, Emitter<OnboardingState> emit) async {
    try {
      // Initialize with selected sports
      final sportProfiles = <int, SportProfileModel>{};
      final availableTags = <int, List<TagModel>>{};
      
      // Create default profiles for each sport
      for (final sport in event.selectedSports) {
        sportProfiles[sport.id] = SportProfileModel(
          sportId: sport.id,
          sportName: sport.name,
          sportIcon: sport.icon,
          skill: 1,
          tags: [],
        );
      }
      
      emit(OnboardingInProgress(
        sports: event.selectedSports,
        sportProfiles: sportProfiles,
        availableTags: availableTags,
      ));
      
      // Load tags for all sports
      add(LoadMultipleTags(sportIds: event.selectedSports.map((s) => s.id).toList()));
    } catch (e) {
      emit(OnboardingError(message: 'Failed to initialize onboarding: ${e.toString()}'));
    }
  }

  Future<void> _onAddSportProfile(AddSportProfile event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      // Check if sport already exists
      if (currentState.sportProfiles.containsKey(event.sport.id)) {
        return;
      }
      
      final updatedSports = List<SportModel>.from(currentState.sports);
      updatedSports.add(event.sport);
      
      final updatedProfiles = Map<int, SportProfileModel>.from(currentState.sportProfiles);
      updatedProfiles[event.sport.id] = SportProfileModel(
        sportId: event.sport.id,
        sportName: event.sport.name,
        sportIcon: event.sport.icon,
        skill: 1,
        tags: [],
      );
      
      emit(OnboardingInProgress(
        sports: updatedSports,
        sportProfiles: updatedProfiles,
        availableTags: currentState.availableTags,
      ));
      
      // Load tags for the new sport
      add(LoadTagsForSport(sportId: event.sport.id));
    }
  }

  Future<void> _onRemoveSportProfile(RemoveSportProfile event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      
      final updatedSports = currentState.sports.where((s) => s.id != event.sportId).toList();
      final updatedProfiles = Map<int, SportProfileModel>.from(currentState.sportProfiles);
      updatedProfiles.remove(event.sportId);
      
      final updatedTags = Map<int, List<TagModel>>.from(currentState.availableTags);
      updatedTags.remove(event.sportId);
      
      emit(OnboardingInProgress(
        sports: updatedSports,
        sportProfiles: updatedProfiles,
        availableTags: updatedTags,
      ));
    }
  }

  Future<void> _onLoadMultipleTags(LoadMultipleTags event, Emitter<OnboardingState> emit) async {
    if (state is OnboardingInProgress) {
      final currentState = state as OnboardingInProgress;
      final updatedTags = Map<int, List<TagModel>>.from(currentState.availableTags);
      
      for (final sportId in event.sportIds) {
        try {
          final tags = await getTagsBySportUseCase.call(sportId);
          updatedTags[sportId] = tags;
        } catch (e) {
          // Continue loading other tags even if one fails
          updatedTags[sportId] = [];
        }
      }
      
      emit(OnboardingInProgress(
        sports: currentState.sports,
        sportProfiles: currentState.sportProfiles,
        availableTags: updatedTags,
      ));
    }
  }
}