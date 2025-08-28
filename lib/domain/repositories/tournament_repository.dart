import 'package:dartz/dartz.dart';

import '../../core/error/failures.dart';
import '../../data/models/tournament_model.dart';
import '../../data/models/team_model.dart';
import '../../data/models/tournament_registration_model.dart';

abstract class TournamentRepository {
  Future<Either<Failure, List<TournamentModel>>> getTournaments();
  Future<Either<Failure, TournamentModel>> getTournamentBySlug(String slug);
  Future<Either<Failure, TournamentRegistrationResponse>> registerForTournament(
    TournamentRegistrationRequest request,
  );
  Future<Either<Failure, PaymentReceiptModel>> getTournamentReceipt(
    int tournamentId,
  );
  Future<Either<Failure, PaymentReceiptModel>> getPublicTournamentReceipt(
    int tournamentId,
  );
  Future<Either<Failure, List<TeamModel>>> getUserTeams(int userId);
  Future<Either<Failure, TeamModel>> createTeam({
    required String name,
    required int userId,
    String? code,
    String? logo,
  });
}