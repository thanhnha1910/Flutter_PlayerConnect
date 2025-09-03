import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/data/models/draft_match_model.dart';
import 'package:player_connect/domain/repositories/community_repository.dart';
import 'package:player_connect/presentation/bloc/auth/auth_bloc.dart';
import 'package:player_connect/presentation/bloc/auth/auth_state.dart';
import 'draft_match_event.dart';
import 'draft_match_state.dart';

@injectable
class DraftMatchBloc extends Bloc<DraftMatchEvent, DraftMatchState> {
  final CommunityRepository communityRepository;
  final AuthBloc authBloc;

  int get _userId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return 0;
  }

  DraftMatchBloc({
    required this.communityRepository,
    required this.authBloc,
  }) : super(DraftMatchInitial()) {
    print('[DraftMatchBloc] Initialized');
    
    // Fetch draft matches events
    on<FetchActiveDraftMatches>(_onFetchActiveDraftMatches);
    on<FetchMyDraftMatches>(_onFetchMyDraftMatches);
    on<FetchPublicDraftMatches>(_onFetchPublicDraftMatches);
    
    // Create draft match event
    on<CreateDraftMatch>(_onCreateDraftMatch);
    
    // Interest management events
    on<ExpressInterest>(_onExpressInterest);
    on<WithdrawInterest>(_onWithdrawInterest);
    
    // User management events
    on<AcceptUser>(_onAcceptUser);
    on<RejectUser>(_onRejectUser);
    
    // Draft match management events
    on<ConvertToMatch>(_onConvertToMatch);
    on<UpdateDraftMatch>(_onUpdateDraftMatch);
    
    // Fetch interested users event
    on<FetchInterestedUsers>(_onFetchInterestedUsers);
    
    // Booking events
    on<InitiateDraftMatchBooking>(_onInitiateDraftMatchBooking);
    on<CompleteDraftMatchBooking>(_onCompleteDraftMatchBooking);
    
    // Ranked and user info events
    on<FetchRankedDraftMatches>(_onFetchRankedDraftMatches);
    on<FetchDraftMatchesWithUserInfo>(_onFetchDraftMatchesWithUserInfo);
    
    // Reset state event
    on<ResetDraftMatchState>(_onResetDraftMatchState);
  }

  Future<void> _onFetchActiveDraftMatches(
    FetchActiveDraftMatches event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchActiveDraftMatches event received');
    emit(DraftMatchLoading());
    
    final result = await communityRepository.getActiveDraftMatches(
      sportType: event.sportType,
      aiRanked: event.aiRanked,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchActiveDraftMatches failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_active'));
      },
      (response) {
        print('[DraftMatchBloc] FetchActiveDraftMatches successful: ${response.data.length} matches');
        emit(DraftMatchListLoaded(response.data, 'active'));
      },
    );
  }

  Future<void> _onFetchMyDraftMatches(
    FetchMyDraftMatches event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchMyDraftMatches event received');
    emit(DraftMatchLoading());
    
    final result = await communityRepository.getMyDraftMatches();
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchMyDraftMatches failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_my'));
      },
      (response) {
        print('[DraftMatchBloc] FetchMyDraftMatches successful: ${response.data.length} matches');
        emit(DraftMatchListLoaded(response.data, 'my'));
      },
    );
  }

  Future<void> _onFetchPublicDraftMatches(
    FetchPublicDraftMatches event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchPublicDraftMatches event received');
    emit(DraftMatchLoading());
    
    final result = await communityRepository.getDraftMatchesWithUserInfo(
      sportType: event.sportType,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchPublicDraftMatches failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_public'));
      },
      (response) {
        print('[DraftMatchBloc] FetchPublicDraftMatches successful: ${response.data.length} matches');
        emit(DraftMatchListLoaded(response.data, 'public'));
      },
    );
  }

  Future<void> _onCreateDraftMatch(
    CreateDraftMatch event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] CreateDraftMatch event received');
    emit(DraftMatchActionLoading('creating'));
    
    final result = await communityRepository.createDraftMatch(event.request);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] CreateDraftMatch failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'create'));
      },
      (response) {
        print('[DraftMatchBloc] CreateDraftMatch successful: ${response.data?.id}');
        emit(DraftMatchCreated(response));
      },
    );
  }

  Future<void> _onExpressInterest(
    ExpressInterest event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] ExpressInterest event received for draft match: ${event.draftMatchId}');
    
    // Optimistic update: immediately update UI
    final currentState = state;
    if (currentState is DraftMatchListLoaded) {
      final optimisticMatches = currentState.draftMatches.map((match) {
        if (match.id == event.draftMatchId) {
          // Create optimistic update with currentUserInterested = true and currentUserStatus = 'PENDING'
          return match.copyWith(
            currentUserInterested: true,
            currentUserStatus: 'PENDING',
            interestedUsersCount: match.interestedUsersCount + 1,
            pendingUsersCount: match.pendingUsersCount + 1,
          );
        }
        return match;
      }).toList();
      
      final newProcessingIds = Set<int>.from(currentState.processingMatchIds);
      newProcessingIds.add(event.draftMatchId);
      
      emit(DraftMatchListLoaded(optimisticMatches, currentState.listType, processingMatchIds: newProcessingIds));
    } else {
      emit(DraftMatchActionLoading('expressing_interest'));
    }
    
    final result = await communityRepository.expressInterest(event.draftMatchId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] ExpressInterest failed: ${failure.toString()}');
        // Remove match from processing state
        final currentState = state;
        if (currentState is DraftMatchListLoaded) {
          final newProcessingIds = Set<int>.from(currentState.processingMatchIds);
          newProcessingIds.remove(event.draftMatchId);
          emit(currentState.copyWithProcessing(newProcessingIds));
        }
        emit(DraftMatchError(failure.toString(), operation: 'express_interest'));
      },
      (response) {
        print('[DraftMatchBloc] ExpressInterest successful for match ${event.draftMatchId}');
        if (response.success) {
          // Refresh the draft matches list to get updated data first
          final currentState = state;
          if (currentState is DraftMatchListLoaded) {
            _refreshDraftMatches(emit, currentState.listType);
            
            // Remove from processing state after refresh
            final updatedState = state;
            if (updatedState is DraftMatchListLoaded) {
              final newProcessingIds = Set<int>.from(updatedState.processingMatchIds);
              newProcessingIds.remove(event.draftMatchId);
              emit(updatedState.copyWithProcessing(newProcessingIds));
            }
          } else {
            // For non-list states, just emit a success state
            emit(DraftMatchOperationSuccess(
              DraftMatchModel(
                id: event.draftMatchId,
                creatorUserId: 0,
                creatorUserName: '',
                sportType: '',
                locationDescription: '',
                estimatedStartTime: DateTime.now(),
                estimatedEndTime: DateTime.now(),
                slotsNeeded: 0,
                skillLevel: '',
                requiredTags: [],
                status: 'ACTIVE',
                createdAt: DateTime.now(),
                interestedUsersCount: 0,
                interestedUserIds: [],
                pendingUsersCount: 0,
                approvedUsersCount: 0,
                userStatuses: [],
                currentUserInterested: true,
                currentUserStatus: 'PENDING',
              ),
              'interest_expressed'
            ));
          }
        } else {
          emit(DraftMatchError(response.message, operation: 'express_interest'));
        }
      },
    );
  }

  Future<void> _onWithdrawInterest(
    WithdrawInterest event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] WithdrawInterest event received for draft match: ${event.draftMatchId}');
    
    // Add match to processing state
    final currentState = state;
    if (currentState is DraftMatchListLoaded) {
      final newProcessingIds = Set<int>.from(currentState.processingMatchIds);
      newProcessingIds.add(event.draftMatchId);
      emit(currentState.copyWithProcessing(newProcessingIds));
    } else {
      emit(DraftMatchActionLoading('withdrawing_interest'));
    }
    
    final result = await communityRepository.withdrawInterest(event.draftMatchId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] WithdrawInterest failed: ${failure.toString()}');
        // Remove match from processing state
        final currentState = state;
        if (currentState is DraftMatchListLoaded) {
          final newProcessingIds = Set<int>.from(currentState.processingMatchIds);
          newProcessingIds.remove(event.draftMatchId);
          emit(currentState.copyWithProcessing(newProcessingIds));
        }
        emit(DraftMatchError(failure.toString(), operation: 'withdraw_interest'));
      },
      (response) {
        print('[DraftMatchBloc] WithdrawInterest successful for match ${event.draftMatchId}');
        if (response.success) {
          // Refresh the draft matches list to get updated data first
          final currentState = state;
          if (currentState is DraftMatchListLoaded) {
            _refreshDraftMatches(emit, currentState.listType);
            
            // Remove from processing state after refresh
            final updatedState = state;
            if (updatedState is DraftMatchListLoaded) {
              final newProcessingIds = Set<int>.from(updatedState.processingMatchIds);
              newProcessingIds.remove(event.draftMatchId);
              emit(updatedState.copyWithProcessing(newProcessingIds));
            }
          } else {
            // For non-list states, just emit a success state
            emit(DraftMatchOperationSuccess(
              DraftMatchModel(
                id: event.draftMatchId,
                creatorUserId: 0,
                creatorUserName: '',
                sportType: '',
                locationDescription: '',
                estimatedStartTime: DateTime.now(),
                estimatedEndTime: DateTime.now(),
                slotsNeeded: 0,
                skillLevel: '',
                requiredTags: [],
                status: 'ACTIVE',
                createdAt: DateTime.now(),
                interestedUsersCount: 0,
                interestedUserIds: [],
                pendingUsersCount: 0,
                approvedUsersCount: 0,
                userStatuses: [],
                currentUserInterested: false,
                currentUserStatus: null,
              ),
              'interest_withdrawn'
            ));
          }
        } else {
          emit(DraftMatchError(response.message, operation: 'withdraw_interest'));
        }
      },
    );
  }

  Future<void> _onAcceptUser(
    AcceptUser event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] AcceptUser event received: draft match ${event.draftMatchId}, user ${event.userId}');
    emit(DraftMatchActionLoading('accepting_user'));
    
    final result = await communityRepository.acceptUser(event.draftMatchId, event.userId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] AcceptUser failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'accept_user'));
      },
      (response) {
        print('[DraftMatchBloc] AcceptUser successful: user ${event.userId} accepted for match ${event.draftMatchId}');
        if (response.data != null) {
          emit(UserAccepted(response.data!, event.userId));
        } else {
          emit(DraftMatchError('No data returned', operation: 'accept_user'));
        }
      },
    );
  }

  Future<void> _onRejectUser(
    RejectUser event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] RejectUser event received: draft match ${event.draftMatchId}, user ${event.userId}');
    emit(DraftMatchActionLoading('rejecting_user'));
    
    final result = await communityRepository.rejectUser(event.draftMatchId, event.userId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] RejectUser failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'reject_user'));
      },
      (response) {
        print('[DraftMatchBloc] RejectUser successful: user ${event.userId} rejected for match ${event.draftMatchId}');
        if (response.data != null) {
          emit(UserRejected(response.data!, event.userId));
        } else {
          emit(DraftMatchError('No data returned', operation: 'reject_user'));
        }
      },
    );
  }

  Future<void> _onConvertToMatch(
    ConvertToMatch event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] ConvertToMatch event received for draft match: ${event.draftMatchId}');
    emit(DraftMatchActionLoading('converting'));
    
    final result = await communityRepository.convertToMatch(event.draftMatchId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] ConvertToMatch failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'convert'));
      },
      (response) {
        print('[DraftMatchBloc] ConvertToMatch successful for match ${event.draftMatchId}');
        if (response.success) {
          // For convert to match, we don't need the data field
          // Just emit success and navigate to search page
          emit(DraftMatchConvertedSuccess(response.message, event.draftMatchId));
        } else {
          emit(DraftMatchError(response.message, operation: 'convert_to_match'));
        }
      },
    );
  }

  Future<void> _onUpdateDraftMatch(
    UpdateDraftMatch event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] UpdateDraftMatch event received for draft match: ${event.draftMatchId}');
    emit(DraftMatchActionLoading('updating'));
    
    final result = await communityRepository.updateDraftMatch(event.draftMatchId, event.request);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] UpdateDraftMatch failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'update'));
      },
      (response) {
        print('[DraftMatchBloc] UpdateDraftMatch successful for match ${event.draftMatchId}');
        if (response.data != null) {
          emit(DraftMatchUpdated(response.data!));
        } else {
          emit(DraftMatchError('No data returned', operation: 'update_draft_match'));
        }
      },
    );
  }

  Future<void> _onFetchInterestedUsers(
    FetchInterestedUsers event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchInterestedUsers event received for draft match: ${event.draftMatchId}');
    emit(DraftMatchActionLoading('fetching_users'));
    
    final result = await communityRepository.getInterestedUsers(event.draftMatchId);
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchInterestedUsers failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_users'));
      },
      (users) {
        print('[DraftMatchBloc] FetchInterestedUsers successful: ${users.length} users');
        emit(InterestedUsersLoaded(users, event.draftMatchId));
      },
    );
  }

  Future<void> _onInitiateDraftMatchBooking(
    InitiateDraftMatchBooking event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] InitiateDraftMatchBooking event received');
    emit(DraftMatchActionLoading('initiating_booking'));
    
    final result = await communityRepository.initiateDraftMatchBooking(
      event.draftMatchId,
      event.bookingData,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] InitiateDraftMatchBooking failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'initiate_booking'));
      },
      (response) {
        print('[DraftMatchBloc] InitiateDraftMatchBooking successful');
        emit(DraftMatchBookingInitiated(response));
      },
    );
  }

  Future<void> _onCompleteDraftMatchBooking(
    CompleteDraftMatchBooking event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] CompleteDraftMatchBooking event received');
    emit(DraftMatchActionLoading('completing_booking'));
    
    final result = await communityRepository.completeDraftMatchBooking(
      event.draftMatchId,
      event.bookingId,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] CompleteDraftMatchBooking failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'complete_booking'));
      },
      (response) {
        print('[DraftMatchBloc] CompleteDraftMatchBooking successful');
        emit(DraftMatchBookingCompleted(response));
      },
    );
  }

  Future<void> _onFetchRankedDraftMatches(
    FetchRankedDraftMatches event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchRankedDraftMatches event received');
    emit(DraftMatchLoading());
    
    final result = await communityRepository.getRankedDraftMatches(
      sportType: event.sportType,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchRankedDraftMatches failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_ranked'));
      },
      (response) {
        print('[DraftMatchBloc] FetchRankedDraftMatches successful: ${response.data.length} matches');
        emit(RankedDraftMatchesLoaded(response.data));
      },
    );
  }

  Future<void> _onFetchDraftMatchesWithUserInfo(
    FetchDraftMatchesWithUserInfo event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] FetchDraftMatchesWithUserInfo event received');
    emit(DraftMatchLoading());
    
    final result = await communityRepository.getDraftMatchesWithUserInfo(
      sportType: event.sportType,
    );
    
    result.fold(
      (failure) {
        print('[DraftMatchBloc] FetchDraftMatchesWithUserInfo failed: ${failure.toString()}');
        emit(DraftMatchError(failure.toString(), operation: 'fetch_with_user_info'));
      },
      (response) {
        print('[DraftMatchBloc] FetchDraftMatchesWithUserInfo successful: ${response.data.length} matches');
        emit(DraftMatchesWithUserInfoLoaded(response.data));
      },
    );
  }

  Future<void> _onResetDraftMatchState(
    ResetDraftMatchState event,
    Emitter<DraftMatchState> emit,
  ) async {
    print('[DraftMatchBloc] ResetDraftMatchState event received');
    emit(DraftMatchInitial());
  }

  Future<void> _refreshDraftMatches(Emitter<DraftMatchState> emit, String listType) async {
    print('[DraftMatchBloc] Refreshing draft matches for list type: $listType');
    
    if (emit.isDone) {
      print('[DraftMatchBloc] Emit is done, skipping refresh');
      return;
    }
    
    // Preserve current processing state
    Set<int> currentProcessingIds = const {};
    final currentState = state;
    if (currentState is DraftMatchListLoaded) {
      currentProcessingIds = currentState.processingMatchIds;
    }
    
    switch (listType) {
      case 'active':
        // For active matches, we need to call getActiveDraftMatches with default parameters
        final result = await communityRepository.getActiveDraftMatches(
          
        );
        if (!emit.isDone) {
          result.fold(
            (failure) => emit(DraftMatchError(failure.toString(), operation: 'refresh_active')),
            (response) => emit(DraftMatchListLoaded(response.data, 'active', processingMatchIds: currentProcessingIds)),
          );
        }
        break;
      case 'my':
        final result = await communityRepository.getMyDraftMatches();
        if (!emit.isDone) {
          result.fold(
            (failure) => emit(DraftMatchError(failure.toString(), operation: 'refresh_my')),
            (response) => emit(DraftMatchListLoaded(response.data, 'my', processingMatchIds: currentProcessingIds)),
          );
        }
        break;
      case 'public':
        // For public matches, use getDraftMatchesWithUserInfo to get user-specific data
        final result = await communityRepository.getDraftMatchesWithUserInfo();
        if (!emit.isDone) {
          result.fold(
            (failure) => emit(DraftMatchError(failure.toString(), operation: 'refresh_public')),
            (response) => emit(DraftMatchListLoaded(response.data, 'public', processingMatchIds: currentProcessingIds)),
          );
        }
        break;
      default:
        print('[DraftMatchBloc] Unknown list type for refresh: $listType');
    }
  }
}