import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:player_connect/presentation/screens/auth/login_screen.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/routing/app_router.dart';
import 'core/observers/simple_bloc_observer.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/location/location_bloc.dart';
import 'presentation/bloc/community/community_bloc.dart';
import 'presentation/bloc/tournament/tournament_bloc.dart';
import 'presentation/screens/main_navigation_screen.dart';
import 'presentation/widgets/loading_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Set up BLoC observer for debugging
  Bloc.observer = SimpleBlocObserver();
  print('🚀 [MAIN] Starting PlayerConnect app with BLoC observer');
  
  configureDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<AuthBloc>()..add(AuthCheckRequested()),
        ),
        BlocProvider(
          create: (context) => getIt<LocationBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<CommunityBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<TournamentBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'PlayerConnect',
        theme: AppTheme.lightTheme,
        onGenerateRoute: AppRouter.generateRoute,
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('=== AuthWrapper: AuthBloc state changed to ${state.runtimeType} ===');
        // Trigger location permission check immediately after authentication
        if (state is Authenticated) {
          print('=== AuthWrapper: User authenticated, dispatching CheckAndRequestPermission ===');
          context.read<LocationBloc>().add(const CheckAndRequestPermission());
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(
              body: LoadingOverlay(
                isLoading: true,
                loadingText: 'Đang kiểm tra đăng nhập...',
                child: SizedBox.expand(),
              ),
            );
          } else if (state is Authenticated) {
            return const MainNavigationScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
