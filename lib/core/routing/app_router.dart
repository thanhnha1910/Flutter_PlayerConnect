import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/main_navigation_screen.dart';
import '../../presentation/screens/chat/create_chat_room_screen.dart';
import '../../presentation/screens/chat/chat_room_screen.dart';
import '../../presentation/screens/tournament/tournament_list_screen.dart';
import '../../presentation/screens/tournament/tournament_detail_screen.dart';
import '../../presentation/screens/tournament/tournament_registration_screen.dart';
import '../../data/models/tournament_model.dart';
import '../../presentation/bloc/chat_messages/chat_rooms_bloc.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String chatRooms = '/chat-rooms';
  static const String createChatRoom = '/create-chat-room';
  static const String chatRoom = '/chat-room';
  static const String tournaments = '/tournaments';
  static const String tournamentDetail = '/tournament-detail';
  static const String tournamentRegistration = '/tournament-registration';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialTabIndex = args?['initialTabIndex'] as int?;
        return MaterialPageRoute(
          builder: (_) => MainNavigationScreen(initialTabIndex: initialTabIndex),
        );
      
      case createChatRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final chatRoomsBloc = args?['chatRoomsBloc'] as ChatRoomsBloc?;
        return MaterialPageRoute(
          builder: (_) => CreateChatRoomScreen(chatRoomsBloc: chatRoomsBloc),
        );
      case chatRoom:
        final args = settings.arguments as Map<String, dynamic>?;
        final roomId = args?['roomId'] as int?;
        final roomName = args?['roomName'] as String?;
        if (roomId != null && roomName != null) {
          return MaterialPageRoute(
            builder: (_) => ChatRoomScreen(
              roomId: roomId,
              roomName: roomName,
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid chat room arguments'),
            ),
          ),
        );
      
      case tournaments:
        return MaterialPageRoute(builder: (_) => const TournamentListScreen());
      
      case tournamentDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final slug = args?['slug'] as String?;
        if (slug != null) {
          return MaterialPageRoute(
            builder: (_) => TournamentDetailScreen(tournamentSlug: slug),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid tournament slug'),
            ),
          ),
        );
      
      case tournamentRegistration:
        final args = settings.arguments as Map<String, dynamic>?;
        final tournament = args?['tournament'] as TournamentModel?;
        if (tournament != null) {
          return MaterialPageRoute(
            builder: (_) => TournamentRegistrationScreen(tournament: tournament),
          );
        }
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Invalid tournament data for registration'),
            ),
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}