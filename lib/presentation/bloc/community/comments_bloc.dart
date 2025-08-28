import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/domain/usecases/community/add_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/get_comments_usecase.dart';
import 'package:player_connect/presentation/bloc/auth/auth_bloc.dart';
import 'package:player_connect/presentation/bloc/auth/auth_state.dart';
import '../../../data/models/comment_model.dart';
import './comments_event.dart';
import './comments_state.dart';

import 'package:player_connect/domain/usecases/community/like_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/reply_to_comment_usecase.dart';

@injectable
class CommentsBloc extends Bloc<CommentsEvent, CommentsState> {
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final ReplyToCommentUseCase replyToCommentUseCase;
  final AuthBloc authBloc;

  int get _userId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return 0; // Or handle this case appropriately
  }

  CommentsBloc({
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.likeCommentUseCase,
    required this.replyToCommentUseCase,
    required this.authBloc,
  }) : super(CommentsInitial()) {
    print('[CommentsBloc] Initialized');
    on<FetchComments>((event, emit) async {
      print('[CommentsBloc] FetchComments event received for postId: ${event.postId}');
      print('[CommentsBloc] Current userId: $_userId');
      emit(CommentsLoading());
      print('[CommentsBloc] Emitted CommentsLoading');
      final failureOrComments = await getCommentsUseCase(GetCommentsParams(postId: event.postId, userId: _userId));
      failureOrComments.fold(
        (failure) {
          print('[CommentsBloc] FetchComments failed: ${failure.toString()}');
          emit(CommentsError(failure.toString()));
          print('[CommentsBloc] Emitted CommentsError');
        },
        (comments) {
          print('[CommentsBloc] Fetched comments data: $comments');
          final flattenedComments = comments
              .expand((comment) => comment.flattenComments())
              .toList();
          print(
              '[CommentsBloc] FetchComments successful: ${flattenedComments.length} comments');
          emit(CommentsLoaded(flattenedComments, comments, event.postId));
          print('[CommentsBloc] Emitted CommentsLoaded');
        },
      );
    });

    on<AddComment>((event, emit) async {
      print('[CommentsBloc] AddComment event received for postId: ${event.postId}, content: ${event.content}');
      print('[CommentsBloc] Current userId: $_userId');
      emit(CommentAdding());
      print('[CommentsBloc] Emitted CommentAdding');
      final failureOrComment = await addCommentUseCase(
          AddCommentParams(postId: event.postId, userId: _userId, request: CommentRequest(content: event.content)));
      failureOrComment.fold(
        (failure) {
          print('[CommentsBloc] AddComment failed: ${failure.toString()}');
          emit(CommentAddError(failure.toString()));
          print('[CommentsBloc] Emitted CommentAddError');
        },
        (_) {
          print('[CommentsBloc] AddComment successful');
          emit(CommentAdded());
          print('[CommentsBloc] Emitted CommentAdded');
          add(FetchComments(event.postId)); // Refresh comments after adding
        },
      );
    });

    on<ToggleCommentExpansion>((event, emit) {
      if (state is CommentsLoaded) {
        final originalComments = (state as CommentsLoaded).originalComments;

        List<CommentResponse> updateComments(List<CommentResponse> comments) {
          return comments.map((comment) {
            if (comment.id == event.commentId) {
              return comment.copyWith(isExpanded: !comment.isExpanded);
            } else if (comment.childComments.isNotEmpty) {
              return comment.copyWith(
                  childComments: updateComments(comment.childComments));
            } else {
              return comment;
            }
          }).toList();
        }

        final newComments = updateComments(originalComments);
        final flattenedComments = newComments
            .expand((comment) => comment.flattenComments())
            .toList();
        emit(CommentsLoaded(flattenedComments, newComments, state.postId!));
      }
    });

    on<LikeComment>((event, emit) async {
      if (state is CommentsLoaded) {
        final originalComments = (state as CommentsLoaded).originalComments;
        final postId = state.postId!;

        List<CommentResponse> updateLikeStatus(List<CommentResponse> comments) {
          return comments.map((comment) {
            if (comment.id == event.commentId) {
              return comment.copyWith(
                  userLikeStatus: comment.userLikeStatus == 1 ? 0 : 1);
            } else if (comment.childComments.isNotEmpty) {
              return comment.copyWith(
                  childComments: updateLikeStatus(comment.childComments));
            } else {
              return comment;
            }
          }).toList();
        }

        final failureOrSuccess = await likeCommentUseCase(
            LikeCommentParams(commentId: event.commentId, userId: _userId));
        failureOrSuccess.fold(
          (failure) => emit(CommentsError(failure.toString())),
          (_) {
            final newOriginalComments = updateLikeStatus(originalComments);
            final flattenedComments = newOriginalComments
                .expand((comment) => comment.flattenComments())
                .toList();
            emit(CommentsLoaded(flattenedComments, newOriginalComments, postId));
          },
        );
      }
    });

    on<ReplyToComment>((event, emit) async {
      if (state is CommentsLoaded) {
        final originalComments = (state as CommentsLoaded).originalComments;
        final postId = state.postId!;

        final failureOrComment = await replyToCommentUseCase(ReplyToCommentParams(
            parentCommentId: event.parentCommentId,
            request: ReplyCommentRequest(
                content: event.content,
                postId: postId,
                userId: _userId)));
        failureOrComment.fold(
          (failure) => emit(CommentsError(failure.toString())),
          (newComment) {
            List<CommentResponse> addReply(List<CommentResponse> comments) {
              return comments.map((comment) {
                if (comment.id == event.parentCommentId) {
                  return comment.copyWith(childComments: [
                    ...comment.childComments,
                    newComment.copyWith(level: comment.level + 1)
                  ]);
                } else if (comment.childComments.isNotEmpty) {
                  return comment.copyWith(
                      childComments: addReply(comment.childComments));
                } else {
                  return comment;
                }
              }).toList();
            }

            final newOriginalComments = addReply(originalComments);
            final flattenedComments = newOriginalComments
                .expand((comment) => comment.flattenComments())
                .toList();
            emit(CommentsLoaded(flattenedComments, newOriginalComments, postId));
          },
        );
      }
    });
  }
}