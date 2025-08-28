import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_remote_datasource.dart';
import '../models/tournament_model.dart';
import '../models/team_model.dart';
import '../models/tournament_registration_model.dart';

@LazySingleton(as: TournamentRepository)
class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource _remoteDataSource;

  TournamentRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<TournamentModel>>> getTournaments() async {
    return await _remoteDataSource.getTournaments();
  }

  @override
  Future<Either<Failure, TournamentModel>> getTournamentBySlug(
    String slug,
  ) async {
    return await _remoteDataSource.getTournamentBySlug(slug);
  }

  @override
  Future<Either<Failure, TournamentRegistrationResponse>> registerForTournament(
    TournamentRegistrationRequest request,
  ) async {
    return await _remoteDataSource.registerForTournament(request);
  }

  @override
  Future<Either<Failure, PaymentReceiptModel>> getTournamentReceipt(
    int tournamentId,
  ) async {
    return await _remoteDataSource.getTournamentReceipt(tournamentId);
  }

  @override
  Future<Either<Failure, PaymentReceiptModel>> getPublicTournamentReceipt(
    int tournamentId,
  ) async {
    return await _remoteDataSource.getPublicTournamentReceipt(tournamentId);
  }

  @override
  Future<Either<Failure, List<TeamModel>>> getUserTeams(int userId) async {
    return await _remoteDataSource.getUserTeams(userId);
  }

  @override
  Future<Either<Failure, TeamModel>> createTeam({
    required String name,
    required int userId,
    String? code,
    String? logo,
  }) async {
    return await _remoteDataSource.createTeam(
      name: name,
      userId: userId,
      code: code,
      logo: logo,
    );
  }
}