import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/draft_match_model.dart';

abstract class DraftMatchEvent extends Equatable {
  const DraftMatchEvent();

  @override
  List<Object?> get props => [];
}

// Fetch draft matches events
class FetchActiveDraftMatches extends DraftMatchEvent {
  final String? sportType;
  final bool? aiRanked;

  const FetchActiveDraftMatches({this.sportType, this.aiRanked});

  @override
  List<Object?> get props => [sportType, aiRanked];
}

class FetchMyDraftMatches extends DraftMatchEvent {}

class FetchPublicDraftMatches extends DraftMatchEvent {
  final String? sportType;
  final bool? aiRanked;

  const FetchPublicDraftMatches({this.sportType, this.aiRanked});

  @override
  List<Object?> get props => [sportType, aiRanked];
}

// Create draft match event
class CreateDraftMatch extends DraftMatchEvent {
  final CreateDraftMatchRequest request;

  const CreateDraftMatch(this.request);

  @override
  List<Object> get props => [request];
}

// Interest management events
class ExpressInterest extends DraftMatchEvent {
  final int draftMatchId;

  const ExpressInterest(this.draftMatchId);

  @override
  List<Object> get props => [draftMatchId];
}

class WithdrawInterest extends DraftMatchEvent {
  final int draftMatchId;

  const WithdrawInterest(this.draftMatchId);

  @override
  List<Object> get props => [draftMatchId];
}

// User management events (for draft match creators)
class AcceptUser extends DraftMatchEvent {
  final int draftMatchId;
  final int userId;

  const AcceptUser(this.draftMatchId, this.userId);

  @override
  List<Object> get props => [draftMatchId, userId];
}

class RejectUser extends DraftMatchEvent {
  final int draftMatchId;
  final int userId;

  const RejectUser(this.draftMatchId, this.userId);

  @override
  List<Object> get props => [draftMatchId, userId];
}

// Draft match management events
class ConvertToMatch extends DraftMatchEvent {
  final int draftMatchId;

  const ConvertToMatch(this.draftMatchId);

  @override
  List<Object> get props => [draftMatchId];
}

class UpdateDraftMatch extends DraftMatchEvent {
  final int draftMatchId;
  final CreateDraftMatchRequest request;

  const UpdateDraftMatch(this.draftMatchId, this.request);

  @override
  List<Object> get props => [draftMatchId, request];
}

// Fetch interested users event
class FetchInterestedUsers extends DraftMatchEvent {
  final int draftMatchId;

  const FetchInterestedUsers(this.draftMatchId);

  @override
  List<Object> get props => [draftMatchId];
}

// Booking events
class InitiateDraftMatchBooking extends DraftMatchEvent {
  final int draftMatchId;
  final Map<String, dynamic> bookingData;

  const InitiateDraftMatchBooking(this.draftMatchId, this.bookingData);

  @override
  List<Object> get props => [draftMatchId, bookingData];
}

class CompleteDraftMatchBooking extends DraftMatchEvent {
  final int draftMatchId;
  final int bookingId;

  const CompleteDraftMatchBooking(this.draftMatchId, this.bookingId);

  @override
  List<Object> get props => [draftMatchId, bookingId];
}

// Fetch ranked draft matches event
class FetchRankedDraftMatches extends DraftMatchEvent {
  final String? sportType;

  const FetchRankedDraftMatches({this.sportType});

  @override
  List<Object?> get props => [sportType];
}

// Fetch draft matches with user info event
class FetchDraftMatchesWithUserInfo extends DraftMatchEvent {
  final String? sportType;

  const FetchDraftMatchesWithUserInfo({this.sportType});

  @override
  List<Object?> get props => [sportType];
}

// Reset state event
class ResetDraftMatchState extends DraftMatchEvent {}