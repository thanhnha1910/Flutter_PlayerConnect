import 'package:equatable/equatable.dart';
import '../../../data/models/tournament_model.dart';
import '../../../data/models/team_model.dart';
import '../../../data/models/tournament_registration_model.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitial extends TournamentState {
  const TournamentInitial();
}

class TournamentLoading extends TournamentState {
  const TournamentLoading();
}

class TournamentsLoaded extends TournamentState {
  final List<TournamentModel> tournaments;

  const TournamentsLoaded({required this.tournaments});

  @override
  List<Object?> get props => [tournaments];
}

class TournamentDetailLoaded extends TournamentState {
  final TournamentModel tournament;

  const TournamentDetailLoaded({required this.tournament});

  @override
  List<Object?> get props => [tournament];
}

class TournamentRegistrationSuccess extends TournamentState {
  final TournamentRegistrationResponse response;

  const TournamentRegistrationSuccess({required this.response});

  @override
  List<Object?> get props => [response];
}

class TournamentReceiptLoaded extends TournamentState {
  final PaymentReceiptModel receipt;

  const TournamentReceiptLoaded({required this.receipt});

  @override
  List<Object?> get props => [receipt];
}

class UserTeamsLoaded extends TournamentState {
  final List<TeamModel> teams;

  const UserTeamsLoaded({required this.teams});

  @override
  List<Object?> get props => [teams];
}

class TeamCreated extends TournamentState {
  final TeamModel team;

  const TeamCreated({required this.team});

  @override
  List<Object?> get props => [team];
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError({required this.message});

  @override
  List<Object?> get props => [message];
}