import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:player_connect/data/models/comment_model.dart';
import 'package:player_connect/domain/usecases/community/add_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/get_comments_usecase.dart';
import 'package:player_connect/domain/usecases/community/get_posts_usecase.dart';
import 'package:player_connect/domain/usecases/community/like_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/like_post_usecase.dart';
import 'package:player_connect/domain/usecases/community/create_post_usecase.dart';
import 'package:player_connect/domain/usecases/community/reply_comment_usecase.dart';
import 'package:player_connect/presentation/bloc/auth/auth_bloc.dart';
import 'package:player_connect/presentation/bloc/auth/auth_state.dart';
import 'package:player_connect/data/datasources/community_remote_datasource.dart';
import './community_event.dart';
import './community_state.dart';

class CommunityBloc extends Bloc<CommunityEvent, CommunityState> {
  final GetPostsUseCase getPostsUseCase;
  final LikePostUseCase likePostUseCase;
  final CreatePostUseCase createPostUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;
  final LikeCommentUseCase likeCommentUseCase;
  final ReplyCommentUseCase replyCommentUseCase;
  final CommunityRemoteDataSource communityRemoteDataSource;
  final AuthBloc authBloc;

  int get _userId {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.id;
    }
    return 0; // Or handle this case appropriately
  }

  CommunityBloc({
    required this.getPostsUseCase,
    required this.likePostUseCase,
    required this.createPostUseCase,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
    required this.likeCommentUseCase,
    required this.replyCommentUseCase,
    required this.communityRemoteDataSource,
    required this.authBloc,
  }) : super(CommunityInitial()) {
    print('[CommunityBloc] Initialized');
    on<FetchPosts>((event, emit) async {
      print('[CommunityBloc] FetchPosts event received');
      print('[CommunityBloc] Current userId: $_userId');
      emit(CommunityLoading());
      final failureOrPosts = await getPostsUseCase(GetPostsParams(userId: _userId));
      print('Result: $failureOrPosts');
      failureOrPosts.fold(
        (failure) {
          print('[CommunityBloc] FetchPosts failed: ${failure.toString()}');
          emit(CommunityError(failure.toString()));
        },
        (posts) {
          print('[CommunityBloc] FetchPosts successful: ${posts.length} posts');
          emit(CommunityLoaded(posts));
        },
      );
    });

    on<LikePost>((event, emit) async {
      print('[CommunityBloc] LikePost event received for postId: ${event.postId}');
      print('[CommunityBloc] Current userId: $_userId');
      final failureOrVoid = await likePostUseCase(LikePostParams(postId: event.postId, userId: _userId));
      failureOrVoid.fold(
        (failure) {
          print('[CommunityBloc] LikePost failed: ${failure.toString()}');
          emit(CommunityError(failure.toString()));
        },
        (_) {
          print('[CommunityBloc] LikePost successful');
          if (state is CommunityLoaded) {
            final currentPosts = (state as CommunityLoaded).posts;
            final updatedPosts = currentPosts.map((post) {
              if (post.id == event.postId) {
                // Toggle like status and update count
                final newLikeStatus = post.userLikeStatus == 1 ? 0 : 1;
                final newLikeCount = post.userLikeStatus == 1 ? post.likeCount - 1 : post.likeCount + 1;
                return post.copyWith(
                  likeCount: newLikeCount,
                  userLikeStatus: newLikeStatus,
                );
              }
              return post;
            }).toList();
            emit(CommunityLoaded(updatedPosts));
          }
        },
      );
    });

    on<CreatePost>((event, emit) async {
      print('[CommunityBloc] CreatePost event received');
      print('[CommunityBloc] Current userId: $_userId');
      final currentState = state;
      emit(CommunityLoading());
      final failureOrPost = await createPostUseCase(event.postRequest.copyWith(userId: _userId));
      failureOrPost.fold(
        (failure) {
          print('[CommunityBloc] CreatePost failed: ${failure.toString()}');
          emit(CreatePostFailure(failure.toString()));
        },
        (post) {
          print('[CommunityBloc] CreatePost successful');
          emit(CreatePostSuccess());
        },
      );
    });

    on<FetchComments>((event, emit) async {
      print('[CommunityBloc] FetchComments event received for postId: ${event.postId}');
      print('[CommunityBloc] Current userId: $_userId');
      emit(CommentsLoading());
      final failureOrComments = await getCommentsUseCase(GetCommentsParams(postId: event.postId, userId: _userId));
      failureOrComments.fold(
        (failure) {
          print('[CommunityBloc] FetchComments failed: ${failure.toString()}');
          emit(CommentsError(failure.toString()));
        },
        (comments) {
          print('[CommunityBloc] FetchComments successful: ${comments.length} comments');
          emit(CommentsLoaded(comments));
        },
      );
    });

    on<AddComment>((event, emit) async {
      print('[CommunityBloc] AddComment event received for postId: ${event.postId}');
      print('[CommunityBloc] Current userId: $_userId');
      final failureOrComment = await addCommentUseCase(
          AddCommentParams(postId: event.postId, userId: _userId, request: CommentRequest(content: event.content)));
      failureOrComment.fold(
        (failure) {
          print('[CommunityBloc] AddComment failed: ${failure.toString()}');
          emit(CommunityError(failure.toString()));
        },
        (_) {
          print('[CommunityBloc] AddComment successful');
          add(FetchComments(event.postId));
        },
      );
    });

    on<LikeComment>((event, emit) async {
      print('[CommunityBloc] LikeComment event received for commentId: ${event.commentId}');
      print('[CommunityBloc] Current userId: $_userId');
      final failureOrVoid = await likeCommentUseCase(LikeCommentParams(commentId: event.commentId, userId: _userId));
      failureOrVoid.fold(
        (failure) {
          print('[CommunityBloc] LikeComment failed: ${failure.toString()}');
          emit(CommunityError(failure.toString()));
        },
        (_) {
          print('[CommunityBloc] LikeComment successful');
          add(FetchComments(event.postId));
        },
      );
    });

    on<ReplyComment>((event, emit) async {
      print('[CommunityBloc] ReplyComment event received for parentCommentId: ${event.parentCommentId}');
      print('[CommunityBloc] Current userId: $_userId');
      final failureOrComment = await replyCommentUseCase(
          ReplyCommentParams(parentCommentId: event.parentCommentId, request: ReplyCommentRequest(content: event.content, postId: event.postId, userId: _userId)));
      failureOrComment.fold(
        (failure) {
          print('[CommunityBloc] ReplyComment failed: ${failure.toString()}');
          emit(CommunityError(failure.toString()));
        },
        (_) {
          print('[CommunityBloc] ReplyComment successful');
          add(FetchComments(event.postId));
        },
      );
    });

    on<GenerateAiContent>((event, emit) async {
      print('[CommunityBloc] GenerateAiContent event received');
      emit(AiContentGenerating());
      try {
        final result = await communityRemoteDataSource.generateAiContent(event.imageBytes);
        print('[CommunityBloc] AI content generated successfully');
        emit(AiContentGenerated(
          title: result['title'] ?? '',
          content: result['content'] ?? '',
        ));
      } catch (e) {
        print('[CommunityBloc] AI content generation failed: ${e.toString()}');
        emit(AiContentGenerationError(e.toString()));
      }
    });
  }
}