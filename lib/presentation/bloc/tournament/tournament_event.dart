import 'package:equatable/equatable.dart';
import '../../../data/models/tournament_registration_model.dart';

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

class LoadTournaments extends TournamentEvent {
  const LoadTournaments();
}

class LoadTournamentBySlug extends TournamentEvent {
  final String slug;

  const LoadTournamentBySlug({required this.slug});

  @override
  List<Object?> get props => [slug];
}

class RegisterForTournament extends TournamentEvent {
  final TournamentRegistrationRequest request;

  const RegisterForTournament({required this.request});

  @override
  List<Object?> get props => [request];
}

class LoadTournamentReceipt extends TournamentEvent {
  final int tournamentId;

  const LoadTournamentReceipt({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class LoadPublicTournamentReceipt extends TournamentEvent {
  final int tournamentId;

  const LoadPublicTournamentReceipt({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}

class LoadUserTeams extends TournamentEvent {
  final int userId;

  const LoadUserTeams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class CreateTeam extends TournamentEvent {
  final String name;
  final String? code;
  final String? logo;
  final int userId;

  const CreateTeam({
    required this.name,
    this.code,
    this.logo,
    required this.userId,
  });

  @override
  List<Object?> get props => [name, code, logo, userId];
}

class ResetTournamentState extends TournamentEvent {
  const ResetTournamentState();
}