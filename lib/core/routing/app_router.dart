import 'package:flutter/material.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/main_navigation_screen.dart';
import '../../presentation/screens/chat/create_chat_room_screen.dart';
import '../../presentation/screens/chat/chat_room_screen.dart';
import '../../presentation/bloc/chat_messages/chat_rooms_bloc.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String chatRooms = '/chat-rooms';
  static const String createChatRoom = '/create-chat-room';
  static const String chatRoom = '/chat-room';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavigationScreen());
      
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