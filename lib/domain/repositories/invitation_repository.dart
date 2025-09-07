import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/unified_invitation_model.dart';
import '../../data/models/open_match_join_request_model.dart';

abstract class InvitationRepository {
  // Unified methods
  Future<Either<Failure, UnifiedInvitationListResponse>>
  getReceivedInvitations({int page = 0, int size = 10});

  Future<Either<Failure, UnifiedInvitationListResponse>> getSentInvitations({
    int page = 0,
    int size = 10,
  });

  // Legacy methods for backward compatibility
  Future<Either<Failure, InvitationListResponse>> getReceivedInvitationsLegacy({
    int page = 0,
    int size = 10,
  });

  Future<Either<Failure, InvitationListResponse>> getSentInvitationsLegacy({
    int page = 0,
    int size = 10,
  });

  Future<Either<Failure, DraftMatchRequestListResponse>>
  getReceivedDraftMatchRequests({int page = 0, int size = 10});

  Future<Either<Failure, DraftMatchRequestListResponse>>
  getSentDraftMatchRequests({int page = 0, int size = 10});

  Future<Either<Failure, void>> respondToInvitation(
    int invitationId,
    InvitationActionRequest request,
  );

  Future<Either<Failure, void>> acceptDraftMatchRequest(
    int draftMatchId,
    int userId,
  );

  Future<Either<Failure, void>> rejectDraftMatchRequest(
    int draftMatchId,
    int userId,
  );

  // Open Match Join Request methods
  Future<Either<Failure, void>> sendOpenMatchJoinRequest(
    int openMatchId,
    SendOpenMatchJoinRequestModel request,
  );

  Future<Either<Failure, OpenMatchJoinRequestListResponse>>
  getReceivedOpenMatchJoinRequests({int page = 0, int size = 10});

  Future<Either<Failure, OpenMatchJoinRequestListResponse>>
  getSentOpenMatchJoinRequests({int page = 0, int size = 10});

  Future<Either<Failure, void>> approveOpenMatchJoinRequest(int requestId);

  Future<Either<Failure, void>> rejectOpenMatchJoinRequest(int requestId);

  Future<Either<Failure, void>> leaveOpenMatch(int openMatchId);
}
