import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../core/constants/api_constants.dart';
import '../../core/error/failures.dart';
import '../../core/network/api_client.dart';
import '../models/tournament_model.dart';
import '../models/team_model.dart';
import '../models/tournament_registration_model.dart';

class ConflictFailure extends Failure {
  const ConflictFailure(super.message);
}

abstract class TournamentRemoteDataSource {
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

@LazySingleton(as: TournamentRemoteDataSource)
class TournamentRemoteDataSourceImpl implements TournamentRemoteDataSource {
  final ApiClient _apiClient;

  TournamentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<Either<Failure, List<TournamentModel>>> getTournaments() async {
    try {
      final response = await _apiClient.dio.get(ApiConstants.tournamentsEndpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final tournaments = data
            .map((json) => TournamentModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(tournaments);
      } else {
        return Left(ServerFailure('Failed to fetch tournaments'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TournamentModel>> getTournamentBySlug(
    String slug,
  ) async {
    try {
      final endpoint = ApiConstants.tournamentBySlugEndpoint
          .replaceAll('{slug}', slug);
      final response = await _apiClient.dio.get(endpoint);
      
      if (response.statusCode == 200) {
        final tournament = TournamentModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(tournament);
      } else {
        return Left(ServerFailure('Failed to fetch tournament'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TournamentRegistrationResponse>> registerForTournament(
    TournamentRegistrationRequest request,
  ) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.tournamentRegisterEndpoint,
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final registration = TournamentRegistrationResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(registration);
      } else {
        return Left(ServerFailure('Failed to register for tournament'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return Left(ValidationFailure(
          e.response?.data['message'] ?? 'Invalid registration data',
        ));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Authentication required'));
      } else if (e.response?.statusCode == 409) {
        return Left(ConflictFailure(
          e.response?.data['message'] ?? 'Already registered',
        ));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentReceiptModel>> getTournamentReceipt(
    int tournamentId,
  ) async {
    try {
      final endpoint = ApiConstants.tournamentReceiptEndpoint
          .replaceAll('{tournamentId}', tournamentId.toString());
      final response = await _apiClient.dio.get(endpoint);
      
      if (response.statusCode == 200) {
        final receipt = PaymentReceiptModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(receipt);
      } else {
        return Left(ServerFailure('Failed to fetch receipt'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentReceiptModel>> getPublicTournamentReceipt(
    int tournamentId,
  ) async {
    try {
      final endpoint = ApiConstants.tournamentPublicReceiptEndpoint
          .replaceAll('{tournamentId}', tournamentId.toString());
      final response = await _apiClient.dio.get(endpoint);
      
      if (response.statusCode == 200) {
        final receipt = PaymentReceiptModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(receipt);
      } else {
        return Left(ServerFailure('Failed to fetch public receipt'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TeamModel>>> getUserTeams(int userId) async {
    try {
      final endpoint = '${ApiConstants.teamsByUserEndpoint}?userId=$userId';
      final response = await _apiClient.dio.get(endpoint);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final teams = data
            .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(teams);
      } else {
        return Left(ServerFailure('Failed to fetch user teams'));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, TeamModel>> createTeam({
    required String name,
    required int userId,
    String? code,
    String? logo,
  }) async {
    try {
      final data = {
        'name': name,
        if (code != null) 'code': code,
        if (logo != null) 'logo': logo,
      };
      
      final response = await _apiClient.dio.post(
        '${ApiConstants.createTeamEndpoint}?userId=$userId',
        data: data,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final team = TeamModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        return Right(team);
      } else {
        return Left(ServerFailure('Failed to create team'));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return Left(ValidationFailure(
          e.response?.data['message'] ?? 'Invalid team data',
        ));
      } else if (e.response?.statusCode == 401) {
        return Left(AuthFailure('Authentication required'));
      }
      return Left(ServerFailure(e.message ?? 'Network error'));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}