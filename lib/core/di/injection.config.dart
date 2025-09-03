// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:player_connect/core/di/register_module.dart' as _i1040;
import 'package:player_connect/core/network/api_client.dart' as _i62;
import 'package:player_connect/core/providers/websocket_provider.dart' as _i82;
import 'package:player_connect/core/services/ai_recommendation_service.dart'
    as _i450;
import 'package:player_connect/core/services/invitation_service.dart' as _i92;
import 'package:player_connect/core/services/location_permission_service.dart'
    as _i187;
import 'package:player_connect/core/services/websocket_service.dart' as _i655;
import 'package:player_connect/core/storage/secure_storage.dart' as _i43;
import 'package:player_connect/data/datasources/auth_remote_datasource.dart'
    as _i287;
import 'package:player_connect/data/datasources/booking_remote_datasource.dart'
    as _i320;
import 'package:player_connect/data/datasources/chat_remote_data_source.dart'
    as _i700;
import 'package:player_connect/data/datasources/chatbot_remote_datasource.dart'
    as _i43;
import 'package:player_connect/data/datasources/community_remote_datasource.dart'
    as _i819;
import 'package:player_connect/data/datasources/invitation_remote_datasource.dart'
    as _i120;
import 'package:player_connect/data/datasources/location_remote_datasource.dart'
    as _i1070;
import 'package:player_connect/data/datasources/notification_remote_datasource.dart'
    as _i550;
import 'package:player_connect/data/datasources/tournament_remote_datasource.dart'
    as _i161;
import 'package:player_connect/data/datasources/user_remote_datasource.dart'
    as _i479;
import 'package:player_connect/data/datasources/websocket_client.dart' as _i683;
import 'package:player_connect/data/repositories/auth_repository_impl.dart'
    as _i136;
import 'package:player_connect/data/repositories/booking_repository_impl.dart'
    as _i1007;
import 'package:player_connect/data/repositories/chat_repository_impl.dart'
    as _i169;
import 'package:player_connect/data/repositories/chatbot_repository_impl.dart'
    as _i278;
import 'package:player_connect/data/repositories/community_repository_impl.dart'
    as _i496;
import 'package:player_connect/data/repositories/invitation_repository_impl.dart'
    as _i127;
import 'package:player_connect/data/repositories/location_repository_impl.dart'
    as _i509;
import 'package:player_connect/data/repositories/notification_repository_impl.dart'
    as _i246;
import 'package:player_connect/data/repositories/tournament_repository_impl.dart'
    as _i206;
import 'package:player_connect/data/repositories/user_repository_impl.dart'
    as _i478;
import 'package:player_connect/domain/repositories/auth_repository.dart'
    as _i1012;
import 'package:player_connect/domain/repositories/booking_repository.dart'
    as _i1040;
import 'package:player_connect/domain/repositories/chat_repository.dart'
    as _i133;
import 'package:player_connect/domain/repositories/chatbot_repository.dart'
    as _i936;
import 'package:player_connect/domain/repositories/community_repository.dart'
    as _i693;
import 'package:player_connect/domain/repositories/invitation_repository.dart'
    as _i229;
import 'package:player_connect/domain/repositories/location_repository.dart'
    as _i339;
import 'package:player_connect/domain/repositories/notification_repository.dart'
    as _i67;
import 'package:player_connect/domain/repositories/tournament_repository.dart'
    as _i533;
import 'package:player_connect/domain/repositories/user_repository.dart'
    as _i779;
import 'package:player_connect/domain/usecases/auth/forgot_password_usecase.dart'
    as _i1066;
import 'package:player_connect/domain/usecases/auth/google_signin_usecase.dart'
    as _i472;
import 'package:player_connect/domain/usecases/auth/login_usecase.dart'
    as _i894;
import 'package:player_connect/domain/usecases/auth/logout_usecase.dart'
    as _i854;
import 'package:player_connect/domain/usecases/auth/register_usecase.dart'
    as _i199;
import 'package:player_connect/domain/usecases/chat/connect_websocket_usecase.dart'
    as _i719;
import 'package:player_connect/domain/usecases/chat/create_chat_room_usecase.dart'
    as _i708;
import 'package:player_connect/domain/usecases/chat/delete_message_usecase.dart'
    as _i415;
import 'package:player_connect/domain/usecases/chat/get_chat_messages_usecase.dart'
    as _i502;
import 'package:player_connect/domain/usecases/chat/get_chat_rooms_usecase.dart'
    as _i729;
import 'package:player_connect/domain/usecases/chat/join_chat_room_usecase.dart'
    as _i847;
import 'package:player_connect/domain/usecases/chat/send_message_usecase.dart'
    as _i1000;
import 'package:player_connect/domain/usecases/chat/subscribe_to_room_usecase.dart'
    as _i312;
import 'package:player_connect/domain/usecases/community/add_comment_usecase.dart'
    as _i461;
import 'package:player_connect/domain/usecases/community/create_post_usecase.dart'
    as _i379;
import 'package:player_connect/domain/usecases/community/get_comments_usecase.dart'
    as _i552;
import 'package:player_connect/domain/usecases/community/get_posts_usecase.dart'
    as _i419;
import 'package:player_connect/domain/usecases/community/like_comment_usecase.dart'
    as _i464;
import 'package:player_connect/domain/usecases/community/like_post_usecase.dart'
    as _i533;
import 'package:player_connect/domain/usecases/community/reply_comment_usecase.dart'
    as _i250;
import 'package:player_connect/domain/usecases/community/reply_to_comment_usecase.dart'
    as _i801;
import 'package:player_connect/domain/usecases/get_active_sports_usecase.dart'
    as _i183;
import 'package:player_connect/domain/usecases/get_location_cards_usecase.dart'
    as _i767;
import 'package:player_connect/domain/usecases/get_location_details_usecase.dart'
    as _i266;
import 'package:player_connect/domain/usecases/get_locations_usecase.dart'
    as _i860;
import 'package:player_connect/domain/usecases/get_tournaments_usecase.dart'
    as _i128;
import 'package:player_connect/domain/usecases/get_venue_details_usecase.dart'
    as _i245;
import 'package:player_connect/domain/usecases/search_locations_usecase.dart'
    as _i598;
import 'package:player_connect/domain/usecases/send_chatbot_message_usecase.dart'
    as _i641;
import 'package:player_connect/domain/usecases/team_management_usecase.dart'
    as _i959;
import 'package:player_connect/domain/usecases/tournament_registration_usecase.dart'
    as _i302;
import 'package:player_connect/presentation/bloc/auth/auth_bloc.dart' as _i976;
import 'package:player_connect/presentation/bloc/chat_messages/chat_messages_bloc.dart'
    as _i1068;
import 'package:player_connect/presentation/bloc/chat_messages/chat_rooms_bloc.dart'
    as _i159;
import 'package:player_connect/presentation/bloc/chatbot/chat_bloc.dart'
    as _i294;
import 'package:player_connect/presentation/bloc/community/comments_bloc.dart'
    as _i927;
import 'package:player_connect/presentation/bloc/community/community_bloc.dart'
    as _i915;
import 'package:player_connect/presentation/bloc/draft_match/draft_match_bloc.dart'
    as _i369;
import 'package:player_connect/presentation/bloc/explore/explore_bloc.dart'
    as _i1035;
import 'package:player_connect/presentation/bloc/home/home_bloc.dart' as _i950;
import 'package:player_connect/presentation/bloc/location/location_bloc.dart'
    as _i633;
import 'package:player_connect/presentation/bloc/notification/notification_bloc.dart'
    as _i667;
import 'package:player_connect/presentation/bloc/tournament/tournament_bloc.dart'
    as _i827;
import 'package:player_connect/presentation/bloc/user/user_bloc.dart' as _i285;
import 'package:player_connect/presentation/bloc/venue_details/venue_details_bloc.dart'
    as _i548;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.secureStorage,
    );
    gh.lazySingleton<_i116.GoogleSignIn>(() => registerModule.googleSignIn);
    gh.lazySingleton<_i519.Client>(() => registerModule.httpClient);
    gh.lazySingleton<String>(() => registerModule.baseUrl);
    gh.lazySingleton<_i187.LocationPermissionService>(
      () => _i187.LocationPermissionService(),
    );
    gh.lazySingleton<_i683.WebSocketClient>(() => _i683.WebSocketClient());
    gh.lazySingleton<_i120.InvitationRemoteDataSource>(
      () => _i120.InvitationRemoteDataSourceImpl(gh<_i361.Dio>()),
    );
    gh.lazySingleton<_i43.SecureStorage>(
      () => _i43.SecureStorage(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i229.InvitationRepository>(
      () => _i127.InvitationRepositoryImpl(
        gh<_i120.InvitationRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i92.InvitationService>(
      () => _i92.InvitationService(gh<_i229.InvitationRepository>()),
    );
    gh.lazySingleton<_i62.ApiClient>(
      () => _i62.ApiClient(gh<_i361.Dio>(), gh<_i43.SecureStorage>()),
    );
    gh.lazySingleton<_i161.TournamentRemoteDataSource>(
      () => _i161.TournamentRemoteDataSourceImpl(gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i700.ChatRemoteDataSource>(
      () => _i700.ChatRemoteDataSourceImpl(
        client: gh<_i519.Client>(),
        baseUrl: gh<String>(),
        secureStorage: gh<_i43.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i479.UserRemoteDataSource>(
      () => _i479.UserRemoteDataSourceImpl(gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i533.TournamentRepository>(
      () => _i206.TournamentRepositoryImpl(
        gh<_i161.TournamentRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i819.CommunityRemoteDataSource>(
      () =>
          _i819.CommunityRemoteDataSourceImpl(apiClient: gh<_i62.ApiClient>()),
    );
    gh.factory<_i655.WebSocketService>(
      () => _i655.WebSocketService(gh<_i43.SecureStorage>()),
    );
    gh.lazySingleton<_i43.ChatbotRemoteDataSource>(
      () => _i43.ChatbotRemoteDataSourceImpl(apiClient: gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i450.AIRecommendationService>(
      () => _i450.AIRecommendationService(gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i959.GetUserTeamsUseCase>(
      () => _i959.GetUserTeamsUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i959.CreateTeamUseCase>(
      () => _i959.CreateTeamUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i302.RegisterForTournamentUseCase>(
      () =>
          _i302.RegisterForTournamentUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i302.GetTournamentReceiptUseCase>(
      () => _i302.GetTournamentReceiptUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i302.GetTournamentPublicReceiptUseCase>(
      () => _i302.GetTournamentPublicReceiptUseCase(
        gh<_i533.TournamentRepository>(),
      ),
    );
    gh.lazySingleton<_i128.GetTournamentsUseCase>(
      () => _i128.GetTournamentsUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i128.GetTournamentBySlugUseCase>(
      () => _i128.GetTournamentBySlugUseCase(gh<_i533.TournamentRepository>()),
    );
    gh.lazySingleton<_i320.BookingRemoteDataSource>(
      () => _i320.BookingRemoteDataSourceImpl(gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i779.UserRepository>(
      () => _i478.UserRepositoryImpl(gh<_i479.UserRemoteDataSource>()),
    );
    gh.lazySingleton<_i1070.LocationRemoteDataSource>(
      () =>
          _i1070.LocationRemoteDataSourceImpl(apiClient: gh<_i62.ApiClient>()),
    );
    gh.lazySingleton<_i287.AuthRemoteDataSource>(
      () => _i287.AuthRemoteDataSourceImpl(
        gh<_i62.ApiClient>(),
        gh<_i116.GoogleSignIn>(),
      ),
    );
    gh.factory<_i827.TournamentBloc>(
      () => _i827.TournamentBloc(
        getTournamentsUseCase: gh<_i128.GetTournamentsUseCase>(),
        getTournamentBySlugUseCase: gh<_i128.GetTournamentBySlugUseCase>(),
        registerForTournamentUseCase: gh<_i302.RegisterForTournamentUseCase>(),
        getTournamentReceiptUseCase: gh<_i302.GetTournamentReceiptUseCase>(),
        getTournamentPublicReceiptUseCase:
            gh<_i302.GetTournamentPublicReceiptUseCase>(),
        getUserTeamsUseCase: gh<_i959.GetUserTeamsUseCase>(),
        createTeamUseCase: gh<_i959.CreateTeamUseCase>(),
      ),
    );
    gh.lazySingleton<_i285.UserBloc>(
      () => _i285.UserBloc(gh<_i779.UserRepository>()),
    );
    gh.lazySingleton<_i550.NotificationRemoteDataSource>(
      () => _i550.NotificationRemoteDataSourceImpl(
        apiClient: gh<_i62.ApiClient>(),
        secureStorage: gh<_i43.SecureStorage>(),
        webSocketService: gh<_i655.WebSocketService>(),
      ),
    );
    gh.lazySingleton<_i339.LocationRepository>(
      () => _i509.LocationRepositoryImpl(
        remoteDataSource: gh<_i1070.LocationRemoteDataSource>(),
      ),
    );
    gh.factory<_i82.WebSocketProvider>(
      () => _i82.WebSocketProvider(
        webSocketService: gh<_i655.WebSocketService>(),
        secureStorage: gh<_i43.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i693.CommunityRepository>(
      () => _i496.CommunityRepositoryImpl(
        remoteDataSource: gh<_i819.CommunityRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i1012.AuthRepository>(
      () => _i136.AuthRepositoryImpl(
        gh<_i287.AuthRemoteDataSource>(),
        gh<_i43.SecureStorage>(),
      ),
    );
    gh.lazySingleton<_i1040.BookingRepository>(
      () => _i1007.BookingRepositoryImpl(gh<_i320.BookingRemoteDataSource>()),
    );
    gh.lazySingleton<_i461.AddCommentUseCase>(
      () => _i461.AddCommentUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i379.CreatePostUseCase>(
      () => _i379.CreatePostUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i464.LikeCommentUseCase>(
      () => _i464.LikeCommentUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i552.GetCommentsUseCase>(
      () => _i552.GetCommentsUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i250.ReplyCommentUseCase>(
      () => _i250.ReplyCommentUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i533.LikePostUseCase>(
      () => _i533.LikePostUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i419.GetPostsUseCase>(
      () => _i419.GetPostsUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i801.ReplyToCommentUseCase>(
      () => _i801.ReplyToCommentUseCase(gh<_i693.CommunityRepository>()),
    );
    gh.lazySingleton<_i936.ChatbotRepository>(
      () => _i278.ChatbotRepositoryImpl(
        remoteDataSource: gh<_i43.ChatbotRemoteDataSource>(),
      ),
    );
    gh.lazySingleton<_i133.ChatRepository>(
      () => _i169.ChatRepositoryImpl(
        remoteDataSource: gh<_i700.ChatRemoteDataSource>(),
        webSocketClient: gh<_i683.WebSocketClient>(),
        secureStorage: gh<_i43.SecureStorage>(),
        authRepository: gh<_i1012.AuthRepository>(),
      ),
    );
    gh.lazySingleton<_i860.GetLocationsUseCase>(
      () => _i860.GetLocationsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i767.GetLocationCardsUseCase>(
      () => _i767.GetLocationCardsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i245.GetVenueDetailsUseCase>(
      () => _i245.GetVenueDetailsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i183.GetActiveSportsUseCase>(
      () => _i183.GetActiveSportsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i266.GetLocationDetailsUseCase>(
      () => _i266.GetLocationDetailsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i598.SearchLocationsUseCase>(
      () => _i598.SearchLocationsUseCase(gh<_i339.LocationRepository>()),
    );
    gh.lazySingleton<_i1066.ForgotPasswordUseCase>(
      () => _i1066.ForgotPasswordUseCase(gh<_i1012.AuthRepository>()),
    );
    gh.lazySingleton<_i199.RegisterUseCase>(
      () => _i199.RegisterUseCase(gh<_i1012.AuthRepository>()),
    );
    gh.lazySingleton<_i894.LoginUseCase>(
      () => _i894.LoginUseCase(gh<_i1012.AuthRepository>()),
    );
    gh.lazySingleton<_i854.LogoutUseCase>(
      () => _i854.LogoutUseCase(gh<_i1012.AuthRepository>()),
    );
    gh.lazySingleton<_i472.GoogleSignInUseCase>(
      () => _i472.GoogleSignInUseCase(gh<_i1012.AuthRepository>()),
    );
    gh.factory<_i719.ConnectWebSocketUseCase>(
      () => _i719.ConnectWebSocketUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i312.SubscribeToRoomUseCase>(
      () => _i312.SubscribeToRoomUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i847.JoinChatRoomUseCase>(
      () => _i847.JoinChatRoomUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i729.GetChatRoomsUseCase>(
      () => _i729.GetChatRoomsUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i502.GetChatMessagesUseCase>(
      () => _i502.GetChatMessagesUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i708.CreateChatRoomUseCase>(
      () => _i708.CreateChatRoomUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i1000.SendMessageUseCase>(
      () => _i1000.SendMessageUseCase(gh<_i133.ChatRepository>()),
    );
    gh.factory<_i159.ChatRoomsBloc>(
      () => _i159.ChatRoomsBloc(
        getChatRoomsUseCase: gh<_i729.GetChatRoomsUseCase>(),
        createChatRoomUseCase: gh<_i708.CreateChatRoomUseCase>(),
        joinChatRoomUseCase: gh<_i847.JoinChatRoomUseCase>(),
        connectWebSocketUseCase: gh<_i719.ConnectWebSocketUseCase>(),
      ),
    );
    gh.lazySingleton<_i67.NotificationRepository>(
      () => _i246.NotificationRepositoryImpl(
        remoteDataSource: gh<_i550.NotificationRemoteDataSource>(),
      ),
    );
    gh.factory<_i633.LocationBloc>(
      () => _i633.LocationBloc(
        locationPermissionService: gh<_i187.LocationPermissionService>(),
        getLocationDetailsUseCase: gh<_i266.GetLocationDetailsUseCase>(),
      ),
    );
    gh.factory<_i641.SendChatbotMessageUseCase>(
      () => _i641.SendChatbotMessageUseCase(gh<_i936.ChatbotRepository>()),
    );
    gh.factory<_i415.DeleteMessageUseCase>(
      () => _i415.DeleteMessageUseCase(gh<_i133.ChatRepository>()),
    );
    gh.lazySingleton<_i976.AuthBloc>(
      () => _i976.AuthBloc(
        loginUseCase: gh<_i894.LoginUseCase>(),
        registerUseCase: gh<_i199.RegisterUseCase>(),
        googleSignInUseCase: gh<_i472.GoogleSignInUseCase>(),
        forgotPasswordUseCase: gh<_i1066.ForgotPasswordUseCase>(),
        logoutUseCase: gh<_i854.LogoutUseCase>(),
        authRepository: gh<_i1012.AuthRepository>(),
      ),
    );
    gh.factory<_i1035.ExploreBloc>(
      () => _i1035.ExploreBloc(
        getLocationsUseCase: gh<_i860.GetLocationsUseCase>(),
        searchLocationsUseCase: gh<_i598.SearchLocationsUseCase>(),
        getLocationCardsUseCase: gh<_i767.GetLocationCardsUseCase>(),
        getActiveSportsUseCase: gh<_i183.GetActiveSportsUseCase>(),
        locationPermissionService: gh<_i187.LocationPermissionService>(),
      ),
    );
    gh.factory<_i294.ChatBloc>(
      () => _i294.ChatBloc(
        sendChatbotMessageUseCase: gh<_i641.SendChatbotMessageUseCase>(),
      ),
    );
    gh.factory<_i369.DraftMatchBloc>(
      () => _i369.DraftMatchBloc(
        communityRepository: gh<_i693.CommunityRepository>(),
        authBloc: gh<_i976.AuthBloc>(),
      ),
    );
    gh.factory<_i950.HomeBloc>(
      () =>
          _i950.HomeBloc(getLocationsUseCase: gh<_i860.GetLocationsUseCase>()),
    );
    gh.factory<_i548.VenueDetailsBloc>(
      () => _i548.VenueDetailsBloc(gh<_i245.GetVenueDetailsUseCase>()),
    );
    gh.factory<_i1068.ChatMessagesBloc>(
      () => _i1068.ChatMessagesBloc(
        gh<_i502.GetChatMessagesUseCase>(),
        gh<_i1000.SendMessageUseCase>(),
        gh<_i312.SubscribeToRoomUseCase>(),
        gh<_i415.DeleteMessageUseCase>(),
        gh<_i700.ChatRemoteDataSource>(),
      ),
    );
    gh.factory<_i927.CommentsBloc>(
      () => _i927.CommentsBloc(
        getCommentsUseCase: gh<_i552.GetCommentsUseCase>(),
        addCommentUseCase: gh<_i461.AddCommentUseCase>(),
        likeCommentUseCase: gh<_i464.LikeCommentUseCase>(),
        replyToCommentUseCase: gh<_i801.ReplyToCommentUseCase>(),
        authBloc: gh<_i976.AuthBloc>(),
      ),
    );
    gh.factory<_i667.NotificationBloc>(
      () => _i667.NotificationBloc(gh<_i67.NotificationRepository>()),
    );
    gh.factory<_i915.CommunityBloc>(
      () => registerModule.communityBloc(
        gh<_i419.GetPostsUseCase>(),
        gh<_i533.LikePostUseCase>(),
        gh<_i379.CreatePostUseCase>(),
        gh<_i552.GetCommentsUseCase>(),
        gh<_i461.AddCommentUseCase>(),
        gh<_i464.LikeCommentUseCase>(),
        gh<_i250.ReplyCommentUseCase>(),
        gh<_i976.AuthBloc>(),
        gh<_i819.CommunityRemoteDataSource>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i1040.RegisterModule {}
