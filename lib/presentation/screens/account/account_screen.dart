import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Placeholder user data
  final Map<String, dynamic> userData = {
    'name': 'Alex Chen',
    'email': 'alex.chen@example.com',
    'avatar': 'AC',
    'joinDate': 'March 2024',
    'matchesPlayed': 47,
    'winRate': 68,
    'favoritesSport': 'Football',
    'level': 'Intermediate',
  };

  final List<Map<String, dynamic>> menuItems = [
    {
      'title': 'Edit Profile',
      'icon': Icons.person_outline,
      'subtitle': 'Update your personal information',
    },
    {
      'title': 'My Teams',
      'icon': Icons.groups_outlined,
      'subtitle': 'Manage your teams and memberships',
    },
    {
      'title': 'Match History',
      'icon': Icons.history,
      'subtitle': 'View your past matches and stats',
    },
    {
      'title': 'Wallet & Payments',
      'icon': Icons.account_balance_wallet_outlined,
      'subtitle': 'Manage your wallet and payment methods',
    },
    {
      'title': 'Notifications',
      'icon': Icons.notifications_outlined,
      'subtitle': 'Configure your notification preferences',
    },
    {
      'title': 'Privacy & Security',
      'icon': Icons.security_outlined,
      'subtitle': 'Manage your privacy and security settings',
    },
    {
      'title': 'Help & Support',
      'icon': Icons.help_outline,
      'subtitle': 'Get help and contact support',
    },
    {
      'title': 'About',
      'icon': Icons.info_outline,
      'subtitle': 'App version and legal information',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildProfileStats(),
          _buildMenuItems(),
          _buildLogoutSection(),
        ],
      ),
    );
  }

  /// Builds the sliver app bar with profile info
  Widget _buildSliverAppBar() {
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
                    child: Text(
                      userData['avatar'],
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Text(
                    userData['name'],
                    style: AppTheme.headingMedium.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    userData['email'],
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
  Widget _buildProfileStats() {
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
                  userData['matchesPlayed'].toString(),
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
                  '${userData['winRate']}%',
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
                  userData['level'],
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
              onTap: () {
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
            _showLogoutDialog();
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
  void _showLogoutDialog() {
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
                // Navigate to login screen
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