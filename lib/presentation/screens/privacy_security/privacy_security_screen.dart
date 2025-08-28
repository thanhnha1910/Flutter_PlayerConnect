import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: const Text(
          'Privacy & Security',
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
            _buildHeaderSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildPrivacySection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildSecuritySection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildDataProtectionSection(),
            const SizedBox(height: AppTheme.spacingXL),
            _buildContactSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: AppTheme.iconSizeLarge,
                ),
              ),
              const SizedBox(width: AppTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Privacy Matters',
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'We are committed to protecting your personal information and ensuring your data security.',
                      style: AppTheme.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      items: [
        _buildInfoItem(
          'Data Collection',
          'We collect only necessary information to provide our services, including your profile data, booking history, and location for field recommendations.',
        ),
        _buildInfoItem(
          'Information Usage',
          'Your data is used to enhance your experience, match you with suitable players, and provide personalized recommendations.',
        ),
        _buildInfoItem(
          'Data Sharing',
          'We do not sell your personal information. Data is shared only with your consent or as required by law.',
        ),
        _buildInfoItem(
          'Your Rights',
          'You have the right to access, update, or delete your personal information at any time through your account settings.',
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSection(
      title: 'Security Measures',
      icon: Icons.shield_outlined,
      items: [
        _buildInfoItem(
          'Data Encryption',
          'All sensitive data is encrypted using industry-standard encryption protocols both in transit and at rest.',
        ),
        _buildInfoItem(
          'Secure Authentication',
          'We use secure authentication methods including password hashing and optional two-factor authentication.',
        ),
        _buildInfoItem(
          'Regular Security Audits',
          'Our systems undergo regular security audits and vulnerability assessments to ensure maximum protection.',
        ),
        _buildInfoItem(
          'Account Security',
          'We recommend using strong passwords and enabling all available security features to protect your account.',
        ),
      ],
    );
  }

  Widget _buildDataProtectionSection() {
    return _buildSection(
      title: 'Data Protection',
      icon: Icons.folder_special_outlined,
      items: [
        _buildInfoItem(
          'Data Retention',
          'We retain your data only as long as necessary to provide our services or as required by applicable laws.',
        ),
        _buildInfoItem(
          'Data Backup',
          'Regular backups are performed to prevent data loss, with all backups following the same security standards.',
        ),
        _buildInfoItem(
          'Third-Party Services',
          'We carefully vet all third-party services and ensure they meet our privacy and security standards.',
        ),
        _buildInfoItem(
          'Compliance',
          'We comply with applicable data protection regulations including GDPR and other local privacy laws.',
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration.copyWith(
        color: AppTheme.primaryAccent.withOpacity(0.05),
        border: Border.all(
          color: AppTheme.primaryAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.contact_support_outlined,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeMedium,
              ),
              const SizedBox(width: AppTheme.spacingM),
              Text(
                'Privacy Concerns?',
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'If you have any questions about our privacy practices or security measures, please don\'t hesitate to contact us.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Row(
            children: [
              Icon(
                Icons.email_outlined,
                color: AppTheme.primaryAccent,
                size: AppTheme.iconSizeSmall,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                'privacy@playerconnect.com',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> items,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusM),
                topRight: Radius.circular(AppTheme.radiusM),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryAccent,
                  size: AppTheme.iconSizeMedium,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  title,
                  style: AppTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            description,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}