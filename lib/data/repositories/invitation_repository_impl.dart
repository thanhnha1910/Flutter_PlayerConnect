import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../datasources/invitation_remote_datasource.dart';
import '../models/invitation_model.dart';
import '../models/open_match_join_request_model.dart';

@LazySingleton(as: InvitationRepository)
class InvitationRepositoryImpl implements InvitationRepository {
  final InvitationRemoteDataSource remoteDataSource;

  InvitationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, InvitationListResponse>> getReceivedInvitations({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final result = await remoteDataSource.getReceivedInvitations(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, InvitationListResponse>> getSentInvitations({
    int page = 0,
    int size = 10,
  }) async {
    try {
      final result = await remoteDataSource.getSentInvitations(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, DraftMatchRequestListResponse>>
  getReceivedDraftMatchRequests({int page = 0, int size = 10}) async {
    try {
      final result = await remoteDataSource.getReceivedDraftMatchRequests(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, DraftMatchRequestListResponse>>
  getSentDraftMatchRequests({int page = 0, int size = 10}) async {
    try {
      final result = await remoteDataSource.getSentDraftMatchRequests(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> respondToInvitation(
    int invitationId,
    InvitationActionRequest request,
  ) async {
    try {
      await remoteDataSource.respondToInvitation(invitationId, request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> acceptDraftMatchRequest(
    int draftMatchId,
    int userId,
  ) async {
    try {
      await remoteDataSource.acceptDraftMatchRequest(draftMatchId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectDraftMatchRequest(
    int draftMatchId,
    int userId,
  ) async {
    try {
      await remoteDataSource.rejectDraftMatchRequest(draftMatchId, userId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> sendOpenMatchJoinRequest(
    int openMatchId,
    SendOpenMatchJoinRequestModel request,
  ) async {
    try {
      await remoteDataSource.sendOpenMatchJoinRequest(openMatchId, request);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, OpenMatchJoinRequestListResponse>>
  getReceivedOpenMatchJoinRequests({int page = 0, int size = 10}) async {
    try {
      final result = await remoteDataSource.getReceivedOpenMatchJoinRequests(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, OpenMatchJoinRequestListResponse>>
  getSentOpenMatchJoinRequests({int page = 0, int size = 10}) async {
    try {
      final result = await remoteDataSource.getSentOpenMatchJoinRequests(
        page: page,
        size: size,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> approveOpenMatchJoinRequest(
    int requestId,
  ) async {
    try {
      await remoteDataSource.approveOpenMatchJoinRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, void>> rejectOpenMatchJoinRequest(
    int requestId,
  ) async {
    try {
      await remoteDataSource.rejectOpenMatchJoinRequest(requestId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error occurred'));
    }
  }
}
