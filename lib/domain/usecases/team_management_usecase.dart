import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/team_model.dart';
import '../repositories/tournament_repository.dart';

@lazySingleton
class GetUserTeamsUseCase {
  final TournamentRepository repository;

  GetUserTeamsUseCase(this.repository);

  Future<Either<Failure, List<TeamModel>>> call(int userId) async {
    return await repository.getUserTeams(userId);
  }
}

@lazySingleton
class CreateTeamUseCase {
  final TournamentRepository repository;

  CreateTeamUseCase(this.repository);

  Future<Either<Failure, TeamModel>> call({
    required String name,
    required int userId,
    String? code,
    String? logo,
  }) async {
    return await repository.createTeam(
      name: name,
      userId: userId,
      code: code,
      logo: logo,
    );
  }
}