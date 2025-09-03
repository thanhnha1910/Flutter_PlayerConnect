import 'package:injectable/injectable.dart';
import 'package:dartz/dartz.dart';
import '../../data/models/ai_recommendation_model.dart';
import '../../data/models/invitation_model.dart';
import '../../domain/repositories/invitation_repository.dart';
import '../error/failures.dart';

@lazySingleton
class InvitationService {
  final InvitationRepository _invitationRepository;

  InvitationService(this._invitationRepository);

  // Get user's sent invitations
  Future<Either<Failure, InvitationListResponse>> getSentInvitations() async {
    return await _invitationRepository.getSentInvitations();
  }

  // Get user's received invitations
  Future<Either<Failure, InvitationListResponse>> getReceivedInvitations() async {
    return await _invitationRepository.getReceivedInvitations();
  }

  // Get user's received draft match requests
  Future<Either<Failure, DraftMatchRequestListResponse>> getReceivedDraftMatchRequests() async {
    return await _invitationRepository.getReceivedDraftMatchRequests();
  }

  // Get user's sent draft match requests
  Future<Either<Failure, DraftMatchRequestListResponse>> getSentDraftMatchRequests() async {
    return await _invitationRepository.getSentDraftMatchRequests();
  }

  // Respond to an invitation (accept/reject)
  Future<Either<Failure, void>> respondToInvitation({
    required int invitationId,
    required String action, // "accept" or "reject"
    String? message,
  }) async {
    final request = InvitationActionRequest(
      action: action,
      message: message,
    );
    return await _invitationRepository.respondToInvitation(invitationId, request);
  }

  // Accept a draft match request
  Future<Either<Failure, void>> acceptDraftMatchRequest(int draftMatchId, int userId) async {
    return await _invitationRepository.acceptDraftMatchRequest(draftMatchId, userId);
  }

  // Reject a draft match request
  Future<Either<Failure, void>> rejectDraftMatchRequest(int draftMatchId, int userId) async {
    return await _invitationRepository.rejectDraftMatchRequest(draftMatchId, userId);
  }

  // Helper method to handle Either results and throw exceptions for UI
  Future<T> _handleResult<T>(Either<Failure, T> result) async {
    return result.fold(
      (failure) {
        if (failure is ServerFailure) {
          throw Exception(failure.message);
        } else {
          throw Exception('Network error occurred');
        }
      },
      (success) => success,
    );
  }

  // Convenience methods that throw exceptions for easier UI handling
  Future<InvitationListResponse> getSentInvitationsOrThrow() async {
    final result = await getSentInvitations();
    return _handleResult(result);
  }

  Future<InvitationListResponse> getReceivedInvitationsOrThrow() async {
    final result = await getReceivedInvitations();
    return _handleResult(result);
  }

  Future<DraftMatchRequestListResponse> getReceivedDraftMatchRequestsOrThrow() async {
    final result = await getReceivedDraftMatchRequests();
    return _handleResult(result);
  }

  Future<DraftMatchRequestListResponse> getSentDraftMatchRequestsOrThrow() async {
    final result = await getSentDraftMatchRequests();
    return _handleResult(result);
  }

  Future<void> respondToInvitationOrThrow({
    required int invitationId,
    required String action,
    String? message,
  }) async {
    final result = await respondToInvitation(
      invitationId: invitationId,
      action: action,
      message: message,
    );
    return _handleResult(result);
  }

  Future<void> acceptDraftMatchRequestOrThrow(int draftMatchId, int userId) async {
    final result = await acceptDraftMatchRequest(draftMatchId, userId);
    return _handleResult(result);
  }

  Future<void> rejectDraftMatchRequestOrThrow(int draftMatchId, int userId) async {
    final result = await rejectDraftMatchRequest(draftMatchId, userId);
    return _handleResult(result);
  }
}
