import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_theme.dart';
import '../../core/di/injection.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/explore/explore_bloc.dart';
import '../bloc/location/location_bloc.dart';
import '../bloc/community/community_bloc.dart'; // Added
import '../bloc/auth/auth_bloc.dart'; // Added
import 'home/home_screen.dart';
import 'explore/explore_screen.dart';
import 'community/community_screen.dart'; // Added
import 'activity/activity_screen.dart';
import 'messages/messages_screen.dart';
import 'account/account_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const ExploreScreen(),
    const CommunityScreen(),
    const ActivityScreen(),
    const MessagesScreen(),
    const AccountScreen(),
  ];

  final List<BottomNavigationBarItem> _navigationItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.explore_outlined),
      activeIcon: Icon(Icons.explore),
      label: 'Explore',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.people_alt_outlined), // Added icon for Community
      activeIcon: Icon(Icons.people_alt), // Added active icon for Community
      label: 'Community', // Added label for Community
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.local_activity_outlined),
      activeIcon: Icon(Icons.local_activity),
      label: 'Activity',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.message_outlined),
      activeIcon: Icon(Icons.message),
      label: 'Messages',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      activeIcon: Icon(Icons.person),
      label: 'Account',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    print('=== MainNavigationScreen: Building with currentIndex $_currentIndex ===');
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeBloc>(
          create: (context) => getIt<HomeBloc>(),
        ),
        BlocProvider<ExploreBloc>(
          create: (context) => getIt<ExploreBloc>(),
        ),
        BlocProvider<LocationBloc>(
          create: (context) => getIt<LocationBloc>(),
        ),
        BlocProvider<CommunityBloc>(
          create: (context) => getIt<CommunityBloc>(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(),
            const ExploreScreen(),
            const CommunityScreen(),
            const ActivityScreen(),
            const MessagesScreen(),
            const AccountScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primaryAccent,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: AppTheme.caption.copyWith(
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTheme.caption,
          elevation: 8,
          items: _navigationItems,
        ),
      ),
    );
  }
}