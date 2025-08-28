import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/failures.dart';
import '../../data/models/tournament_registration_model.dart';
import '../repositories/tournament_repository.dart';

@lazySingleton
class RegisterForTournamentUseCase {
  final TournamentRepository repository;

  RegisterForTournamentUseCase(this.repository);

  Future<Either<Failure, TournamentRegistrationResponse>> call(
    TournamentRegistrationRequest request,
  ) async {
    return await repository.registerForTournament(request);
  }
}

@lazySingleton
class GetTournamentReceiptUseCase {
  final TournamentRepository repository;

  GetTournamentReceiptUseCase(this.repository);

  Future<Either<Failure, PaymentReceiptModel>> call(int tournamentId) async {
    return await repository.getTournamentReceipt(tournamentId);
  }
}

@lazySingleton
class GetTournamentPublicReceiptUseCase {
  final TournamentRepository repository;

  GetTournamentPublicReceiptUseCase(this.repository);

  Future<Either<Failure, PaymentReceiptModel>> call(int tournamentId) async {
    return await repository.getPublicTournamentReceipt(tournamentId);
  }
}