import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'About PlayerConnect',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.primaryAccent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppInfoSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildMissionSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildFeaturesSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildTeamSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildVersionSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildLegalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration.copyWith(
        gradient: LinearGradient(
          colors: [AppTheme.primaryAccent, AppTheme.primaryAccent.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 60,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'PlayerConnect',
            style: AppTheme.headingLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Connecting Athletes, Building Communities',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Version 1.0.0',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Our Mission',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'PlayerConnect is dedicated to revolutionizing how athletes connect, play, and grow together. We believe that sports have the power to bring people together, build lasting friendships, and create vibrant communities.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Our platform makes it easier than ever to find teammates, book sports facilities, and discover new opportunities to stay active and engaged in your favorite sports.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Key Features',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildFeatureItem(
            Icons.search,
            'Smart Field Discovery',
            'Find and book sports facilities near you with real-time availability.',
          ),
          _buildFeatureItem(
            Icons.people_outline,
            'AI Friend Finder',
            'Get matched with players based on your skill level and preferences.',
          ),
          _buildFeatureItem(
            Icons.calendar_today,
            'Easy Booking System',
            'Book fields, courts, and facilities with just a few taps.',
          ),
          _buildFeatureItem(
            Icons.location_on_outlined,
            'Location-Based Search',
            'Discover sports opportunities and players in your area.',
          ),
          _buildFeatureItem(
            Icons.trending_up,
            'Skill Development',
            'Track your progress and improve your game with detailed analytics.',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryAccent,
              size: AppTheme.iconSizeSmall,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration.copyWith(
        color: AppTheme.primaryAccent.withOpacity(0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group_outlined,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Our Team',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          Text(
            'PlayerConnect is built by a passionate team of developers, designers, and sports enthusiasts who understand the challenges of finding the right teammates and facilities.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'We\'re committed to creating innovative solutions that make sports more accessible and enjoyable for everyone.',
            style: AppTheme.bodyMedium.copyWith(
              height: 1.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingL),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildTeamStat('50K+', 'Active Users'),
              _buildTeamStat('1000+', 'Sports Facilities'),
              _buildTeamStat('25+', 'Cities'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStat(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: AppTheme.headingMedium.copyWith(
            color: AppTheme.primaryAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppTheme.spacingXS),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Version Information',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildVersionItem('App Version', '1.0.0'),
          _buildVersionItem('Build Number', '100'),
          _buildVersionItem('Release Date', 'January 2024'),
          _buildVersionItem('Platform', 'iOS & Android'),
          _buildVersionItem('Minimum OS', 'iOS 12.0, Android 6.0'),
        ],
      ),
    );
  }

  Widget _buildVersionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel_outlined,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Legal & Policies',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingL),
          _buildLegalItem(
            'Terms of Service',
            'Read our terms and conditions',
            () {},
          ),
          _buildLegalItem(
            'Privacy Policy',
            'Learn how we protect your data',
            () {},
          ),
          _buildLegalItem(
            'Open Source Licenses',
            'View third-party licenses',
            () {},
          ),
          _buildLegalItem(
            'Contact Legal Team',
            'legal@playerconnect.com',
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppTheme.spacingM,
          horizontal: AppTheme.spacingS,
        ),
        margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
          border: Border.all(
            color: AppTheme.primaryAccent.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXS),
                  Text(
                    subtitle,
                    style: AppTheme.caption.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppTheme.textSecondary,
              size: AppTheme.iconSizeSmall,
            ),
          ],
        ),
      ),
    );
  }
}