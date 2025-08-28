import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/tournament_model.dart';
import '../repositories/tournament_repository.dart';

@lazySingleton
class GetTournamentsUseCase {
  final TournamentRepository repository;

  GetTournamentsUseCase(this.repository);

  Future<Either<Failure, List<TournamentModel>>> call() async {
    return await repository.getTournaments();
  }
}

@lazySingleton
class GetTournamentBySlugUseCase {
  final TournamentRepository repository;

  GetTournamentBySlugUseCase(this.repository);

  Future<Either<Failure, TournamentModel>> call(String slug) async {
    return await repository.getTournamentBySlug(slug);
  }
}