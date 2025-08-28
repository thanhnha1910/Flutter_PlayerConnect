import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/usecases/get_tournaments_usecase.dart';
import '../../../domain/usecases/tournament_registration_usecase.dart';
import '../../../domain/usecases/team_management_usecase.dart';
import 'tournament_event.dart';
import 'tournament_state.dart';

@injectable
class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final GetTournamentsUseCase getTournamentsUseCase;
  final GetTournamentBySlugUseCase getTournamentBySlugUseCase;
  final RegisterForTournamentUseCase registerForTournamentUseCase;
  final GetTournamentReceiptUseCase getTournamentReceiptUseCase;
  final GetTournamentPublicReceiptUseCase getTournamentPublicReceiptUseCase;
  final GetUserTeamsUseCase getUserTeamsUseCase;
  final CreateTeamUseCase createTeamUseCase;

  TournamentBloc({
    required this.getTournamentsUseCase,
    required this.getTournamentBySlugUseCase,
    required this.registerForTournamentUseCase,
    required this.getTournamentReceiptUseCase,
    required this.getTournamentPublicReceiptUseCase,
    required this.getUserTeamsUseCase,
    required this.createTeamUseCase,
  }) : super(const TournamentInitial()) {
    print('[TournamentBloc] Initialized');
    
    on<LoadTournaments>(_onLoadTournaments);
    on<LoadTournamentBySlug>(_onLoadTournamentBySlug);
    on<RegisterForTournament>(_onRegisterForTournament);
    on<LoadTournamentReceipt>(_onLoadTournamentReceipt);
    on<LoadPublicTournamentReceipt>(_onLoadPublicTournamentReceipt);
    on<LoadUserTeams>(_onLoadUserTeams);
    on<CreateTeam>(_onCreateTeam);
    on<ResetTournamentState>(_onResetTournamentState);
  }

  Future<void> _onLoadTournaments(
    LoadTournaments event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Loading tournaments...');
      emit(const TournamentLoading());
      
      final result = await getTournamentsUseCase();
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to load tournaments: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (tournaments) {
          print('[TournamentBloc] Successfully loaded ${tournaments.length} tournaments');
          emit(TournamentsLoaded(tournaments: tournaments));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onLoadTournaments: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onLoadTournamentBySlug(
    LoadTournamentBySlug event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Loading tournament by slug: ${event.slug}');
      emit(const TournamentLoading());
      
      final result = await getTournamentBySlugUseCase(event.slug);
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to load tournament: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (tournament) {
          print('[TournamentBloc] Successfully loaded tournament: ${tournament.name}');
          emit(TournamentDetailLoaded(tournament: tournament));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onLoadTournamentBySlug: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onRegisterForTournament(
    RegisterForTournament event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Registering for tournament...');
      emit(const TournamentLoading());
      
      final result = await registerForTournamentUseCase(event.request);
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to register: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (response) {
          print('[TournamentBloc] Successfully registered for tournament');
          emit(TournamentRegistrationSuccess(response: response));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onRegisterForTournament: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onLoadTournamentReceipt(
    LoadTournamentReceipt event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Loading tournament receipt for ID: ${event.tournamentId}');
      emit(const TournamentLoading());
      
      final result = await getTournamentReceiptUseCase(event.tournamentId);
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to load receipt: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (receipt) {
          print('[TournamentBloc] Successfully loaded tournament receipt');
          emit(TournamentReceiptLoaded(receipt: receipt));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onLoadTournamentReceipt: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onLoadPublicTournamentReceipt(
    LoadPublicTournamentReceipt event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Loading public tournament receipt for ID: ${event.tournamentId}');
      emit(const TournamentLoading());
      
      final result = await getTournamentPublicReceiptUseCase(event.tournamentId);
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to load public receipt: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (receipt) {
          print('[TournamentBloc] Successfully loaded public tournament receipt');
          emit(TournamentReceiptLoaded(receipt: receipt));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onLoadPublicTournamentReceipt: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onLoadUserTeams(
    LoadUserTeams event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Loading user teams for user ID: ${event.userId}');
      emit(const TournamentLoading());
      
      final result = await getUserTeamsUseCase(event.userId);
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to load user teams: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (teams) {
          print('[TournamentBloc] Successfully loaded ${teams.length} user teams');
          emit(UserTeamsLoaded(teams: teams));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onLoadUserTeams: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onCreateTeam(
    CreateTeam event,
    Emitter<TournamentState> emit,
  ) async {
    try {
      print('[TournamentBloc] Creating team: ${event.name}');
      emit(const TournamentLoading());
      
      final result = await createTeamUseCase(
        name: event.name,
        code: event.code,
        logo: event.logo,
        userId: event.userId,
      );
      
      result.fold(
        (failure) {
          print('[TournamentBloc] Failed to create team: ${failure.message}');
          emit(TournamentError(message: failure.message));
        },
        (team) {
          print('[TournamentBloc] Successfully created team: ${team.name}');
          emit(TeamCreated(team: team));
        },
      );
    } catch (e) {
      print('[TournamentBloc] Exception in _onCreateTeam: $e');
      emit(TournamentError(message: 'Unexpected error: $e'));
    }
  }

  Future<void> _onResetTournamentState(
    ResetTournamentState event,
    Emitter<TournamentState> emit,
  ) async {
    print('[TournamentBloc] Resetting tournament state');
    emit(const TournamentInitial());
  }
}