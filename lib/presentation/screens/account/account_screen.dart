import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';
import '../booking_history/booking_history_screen.dart';
import '../change_password/change_password_screen.dart';
import '../privacy_security/privacy_security_screen.dart';
import '../help_support/help_support_screen.dart';
import '../about/about_screen.dart';
import 'profile_screen.dart';
import '../invitation/invitation_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final userBloc = context.read<UserBloc>();
          print('=== AccountScreen: Found UserBloc instance: $userBloc ===');
          userBloc.add(LoadUserProfile());
        } catch (e) {
          print('=== AccountScreen: Error accessing UserBloc: $e ===');
          // Handle the case where UserBloc is not available
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load user profile. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }

  void _navigateToBookingHistory() {
    try {
      final userBloc = context.read<UserBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: userBloc,
            child: const BookingHistoryScreen(),
          ),
        ),
      );
    } catch (e) {
      print('=== AccountScreen: Error accessing UserBloc for booking history: $e ===');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access booking history. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToChangePassword() {
    try {
      final userBloc = context.read<UserBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => BlocProvider.value(
            value: userBloc,
            child: const ChangePasswordScreen(),
          ),
        ),
      );
    } catch (e) {
      print('=== AccountScreen: Error accessing UserBloc for change password: $e ===');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access change password. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToPrivacySecurity() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrivacySecurityScreen(),
      ),
    );
  }

  void _navigateToHelpSupport() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const HelpSupportScreen(),
      ),
    );
  }

  void _navigateToAbout() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutScreen(),
      ),
    );
  }

  void _navigateToInvitations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const InvitationScreen(),
      ),
    );
  }

  void _navigateToProfile() {
    try {
      final userBloc = context.read<UserBloc>();
      final authBloc = context.read<AuthBloc>();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: userBloc,
              ),
              BlocProvider.value(
                value: authBloc,
              ),
            ],
            child: const ProfileScreen(),
          ),
        ),
      );
    } catch (e) {
      print('=== AccountScreen: Error accessing BLoCs for profile: $e ===');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to access profile. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<Map<String, dynamic>> get menuItems => [
    {
      'title': 'Profile Information',
      'icon': Icons.person_outline,
      'subtitle': 'View your personal information and account details',
      'onTap': () => _navigateToProfile(),
    },
    {
      'title': 'Booking History',
      'icon': Icons.history,
      'subtitle': 'View your booking history and past matches',
      'onTap': () => _navigateToBookingHistory(),
    },
    {
      'title': 'Invitations & Requests',
      'icon': Icons.mail_outline,
      'subtitle': 'Manage team invitations and match requests',
      'onTap': () => _navigateToInvitations(),
    },
    {
      'title': 'Change Password',
      'icon': Icons.lock_outline,
      'subtitle': 'Update your account password',
      'onTap': () => _navigateToChangePassword(),
    },
    {
      'title': 'Privacy & Security',
      'icon': Icons.security_outlined,
      'subtitle': 'Manage your privacy and security settings',
      'onTap': () => _navigateToPrivacySecurity(),
    },
    {
      'title': 'Help & Support',
      'icon': Icons.help_outline,
      'subtitle': 'Get help and contact support',
      'onTap': () => _navigateToHelpSupport(),
    },
    {
      'title': 'About',
      'icon': Icons.info_outline,
      'subtitle': 'App version and legal information',
      'onTap': () => _navigateToAbout(),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        if (state is UserLoading) {
          return const Scaffold(
            backgroundColor: AppTheme.scaffoldBackground,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        if (state is UserError) {
          return Scaffold(
            backgroundColor: AppTheme.scaffoldBackground,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading profile',
                    style: AppTheme.headingMedium,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UserBloc>().add(LoadUserProfile());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        
        final user = state is UserProfileLoaded ? state.user : null;
        
        return Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          body: CustomScrollView(
            slivers: [
              _buildSliverAppBar(user),
              _buildProfileStats(user),
              _buildMenuItems(),
              _buildLogoutSection(),
            ],
          ),
        );
      },
    );
  }

  /// Builds the sliver app bar with profile info
  Widget _buildSliverAppBar(UserModel? user) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: AppTheme.spacingXL),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: user?.profilePicture != null 
                        ? NetworkImage(user!.profilePicture!) 
                        : null,
                    child: user?.profilePicture == null
                        ? Text(
                            user?.fullName?.substring(0, 2).toUpperCase() ?? 'U',
                            style: AppTheme.headingMedium.copyWith(
                              color: Colors.white,
                              fontSize: 28,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    user?.fullName ?? 'Unknown User',
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    user?.email ?? 'No email',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // Handle settings
          },
        ),
      ],
    );
  }

  /// Builds profile statistics
  Widget _buildProfileStats(UserModel? user) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingL),
        decoration: AppTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Matches',
                  user?.bookingCount?.toString() ?? '0',
                  Icons.sports_soccer,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildStatItem(
                  'Win Rate',
                  '0%', // Win rate not available in current model
                  Icons.emoji_events,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppTheme.borderColor,
              ),
              Expanded(
                child: _buildStatItem(
                  'Level',
                  user?.memberLevel?.toString() ?? 'Beginner',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a stat item
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryAccent,
          size: AppTheme.iconSizeMedium,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Text(
          value,
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds menu items
  Widget _buildMenuItems() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = menuItems[index];
          return Container(
            margin: EdgeInsets.only(
              left: AppTheme.spacingL,
              right: AppTheme.spacingL,
              bottom: index == menuItems.length - 1 ? AppTheme.spacingL : AppTheme.spacingS,
            ),
            decoration: AppTheme.cardDecoration,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
                vertical: AppTheme.spacingS,
              ),
              leading: Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Icon(
                  item['icon'],
                  color: AppTheme.primaryAccent,
                  size: AppTheme.iconSizeMedium,
                ),
              ),
              title: Text(
                item['title'],
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                item['subtitle'],
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
                size: AppTheme.iconSizeMedium,
              ),
              onTap: item['onTap'] ?? () {
                // Handle menu item tap
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item['title']} tapped'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          );
        },
        childCount: menuItems.length,
      ),
    );
  }

  /// Builds logout section
  Widget _buildLogoutSection() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppTheme.spacingL),
        child: ElevatedButton(
          onPressed: () {
            _showLogoutDialog(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            foregroundColor: Colors.red.shade700,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              side: BorderSide(
                color: Colors.red.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'Logout',
                style: AppTheme.buttonText.copyWith(
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement logout functionality
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}