import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import 'package:http/http.dart' as http;
import 'package:player_connect/presentation/bloc/auth/auth_bloc.dart';
import 'package:player_connect/presentation/bloc/community/community_bloc.dart';
import 'package:player_connect/domain/usecases/community/add_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/create_post_usecase.dart';
import 'package:player_connect/domain/usecases/community/get_comments_usecase.dart';
import 'package:player_connect/domain/usecases/community/get_posts_usecase.dart';
import 'package:player_connect/domain/usecases/community/like_comment_usecase.dart';
import 'package:player_connect/domain/usecases/community/like_post_usecase.dart';
import 'package:player_connect/domain/usecases/community/reply_comment_usecase.dart';
import '../constants/api_constants.dart';
import 'injection.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Dio get dio => Dio();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage();

  @lazySingleton
  GoogleSignIn get googleSignIn => GoogleSignIn(
        // clientId: '339980816419-dl1cgrs4dbaoc2od21thd11a5aivaq67.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

  @lazySingleton
  http.Client get httpClient => http.Client();

  @lazySingleton
  String get baseUrl => ApiConstants.baseUrl;

  @lazySingleton
  AuthBloc authBloc() => AuthBloc(
        loginUseCase: getIt(),
        registerUseCase: getIt(),
        googleSignInUseCase: getIt(),
        forgotPasswordUseCase: getIt(),
        logoutUseCase: getIt(),
        authRepository: getIt(),
      );

  @injectable
  @lazySingleton
  CommunityBloc communityBloc(
    GetPostsUseCase getPostsUseCase,
    LikePostUseCase likePostUseCase,
    CreatePostUseCase createPostUseCase,
    GetCommentsUseCase getCommentsUseCase,
    AddCommentUseCase addCommentUseCase,
    LikeCommentUseCase likeCommentUseCase,
    ReplyCommentUseCase replyCommentUseCase,
    AuthBloc authBloc,
  ) =>
      CommunityBloc(
        getPostsUseCase: getPostsUseCase,
        likePostUseCase: likePostUseCase,
        createPostUseCase: createPostUseCase,
        getCommentsUseCase: getCommentsUseCase,
        addCommentUseCase: addCommentUseCase,
        likeCommentUseCase: likeCommentUseCase,
        replyCommentUseCase: replyCommentUseCase,
        authBloc: authBloc,
      );
}