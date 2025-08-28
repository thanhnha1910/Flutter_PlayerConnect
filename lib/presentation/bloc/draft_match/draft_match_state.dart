import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/draft_match_model.dart';
import 'package:player_connect/data/models/user_model.dart';

abstract class DraftMatchState extends Equatable {
  const DraftMatchState();

  @override
  List<Object?> get props => [];
}

// Initial state
class DraftMatchInitial extends DraftMatchState {}

// Loading states
class DraftMatchLoading extends DraftMatchState {}

class DraftMatchActionLoading extends DraftMatchState {
  final String action;

  const DraftMatchActionLoading(this.action);

  @override
  List<Object> get props => [action];
}

// Success states for draft match lists
class DraftMatchListLoaded extends DraftMatchState {
  final List<DraftMatchModel> draftMatches;
  final String listType; // 'active', 'my', 'public'

  const DraftMatchListLoaded(this.draftMatches, this.listType);

  @override
  List<Object> get props => [draftMatches, listType];
}

// Success state for single draft match operations
class DraftMatchOperationSuccess extends DraftMatchState {
  final DraftMatchModel draftMatch;
  final String operation; // 'created', 'updated', 'converted', 'interest_expressed', etc.

  const DraftMatchOperationSuccess(this.draftMatch, this.operation);

  @override
  List<Object> get props => [draftMatch, operation];
}

// Success state for interested users
class InterestedUsersLoaded extends DraftMatchState {
  final List<UserModel> users;
  final int draftMatchId;

  const InterestedUsersLoaded(this.users, this.draftMatchId);

  @override
  List<Object> get props => [users, draftMatchId];
}

// Error states
class DraftMatchError extends DraftMatchState {
  final String message;
  final String? operation;

  const DraftMatchError(this.message, {this.operation});

  @override
  List<Object?> get props => [message, operation];
}

// Specific success states for better UI feedback
class DraftMatchCreated extends DraftMatchState {
  final DraftMatchResponse draftMatch;

  const DraftMatchCreated(this.draftMatch);

  @override
  List<Object> get props => [draftMatch];
}

class InterestExpressed extends DraftMatchState {
  final DraftMatchModel draftMatch;

  const InterestExpressed(this.draftMatch);

  @override
  List<Object> get props => [draftMatch];
}

class InterestWithdrawn extends DraftMatchState {
  final DraftMatchModel draftMatch;

  const InterestWithdrawn(this.draftMatch);

  @override
  List<Object> get props => [draftMatch];
}

class UserAccepted extends DraftMatchState {
  final DraftMatchModel draftMatch;
  final int acceptedUserId;

  const UserAccepted(this.draftMatch, this.acceptedUserId);

  @override
  List<Object> get props => [draftMatch, acceptedUserId];
}

class UserRejected extends DraftMatchState {
  final DraftMatchModel draftMatch;
  final int rejectedUserId;

  const UserRejected(this.draftMatch, this.rejectedUserId);

  @override
  List<Object> get props => [draftMatch, rejectedUserId];
}

class DraftMatchConverted extends DraftMatchState {
  final DraftMatchModel draftMatch;

  const DraftMatchConverted(this.draftMatch);

  @override
  List<Object> get props => [draftMatch];
}

class DraftMatchUpdated extends DraftMatchState {
  final DraftMatchModel draftMatch;

  const DraftMatchUpdated(this.draftMatch);

  @override
  List<Object> get props => [draftMatch];
}

// Booking states
class DraftMatchBookingInitiated extends DraftMatchState {
  final DraftMatchResponse bookingResponse;

  const DraftMatchBookingInitiated(this.bookingResponse);

  @override
  List<Object> get props => [bookingResponse];
}

class DraftMatchBookingCompleted extends DraftMatchState {
  final DraftMatchResponse bookingResponse;

  const DraftMatchBookingCompleted(this.bookingResponse);

  @override
  List<Object> get props => [bookingResponse];
}

// Ranked draft matches state
class RankedDraftMatchesLoaded extends DraftMatchState {
  final List<DraftMatchModel> rankedMatches;

  const RankedDraftMatchesLoaded(this.rankedMatches);

  @override
  List<Object> get props => [rankedMatches];
}

// Draft matches with user info state
class DraftMatchesWithUserInfoLoaded extends DraftMatchState {
  final List<DraftMatchModel> matchesWithUserInfo;

  const DraftMatchesWithUserInfoLoaded(this.matchesWithUserInfo);

  @override
  List<Object> get props => [matchesWithUserInfo];
}