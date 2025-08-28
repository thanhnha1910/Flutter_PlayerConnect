import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';
import 'tournament_list_screen.dart';

class TournamentReceiptScreen extends StatelessWidget {
  final TournamentModel tournament;
  final String paymentId;
  final int teamId;
  final String? teamName;

  const TournamentReceiptScreen({
    super.key,
    required this.tournament,
    required this.paymentId,
    required this.teamId,
    this.teamName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryAccent,
        foregroundColor: Colors.white,
        title: const Text('Biên nhận đăng ký'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Icon and Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Registration Successful!',
                    style: AppTheme.headingLarge.copyWith(
                      color: AppTheme.successColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your team has been successfully registered for the tournament.',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tournament Details
            _buildSectionCard(
              title: 'Tournament Details',
              children: [
                _buildDetailRow('Tournament Name', tournament.name ?? 'N/A'),
                _buildDetailRow('Location', tournament.location ?? 'N/A'),
                _buildDetailRow('Start Date', _formatDate(tournament.startDate)),
                _buildDetailRow('End Date', _formatDate(tournament.endDate)),
                _buildDetailRow('Entry Fee', '\$${tournament.registrationFee?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow('Max Teams', '${tournament.maxTeams ?? 'N/A'}'),
              ],
            ),
            const SizedBox(height: 16),

            // Team Details
            _buildSectionCard(
              title: 'Team Information',
              children: [
                _buildDetailRow('Team ID', '#$teamId'),
                if (teamName != null) _buildDetailRow('Team Name', teamName!),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Details
            _buildSectionCard(
              title: 'Payment Information',
              children: [
                _buildDetailRow('Payment ID', paymentId),
                _buildDetailRow('Amount Paid', '\$${tournament.registrationFee?.toStringAsFixed(2) ?? '0.00'}'),
                _buildDetailRow('Payment Method', 'PayPal'),
                _buildDetailRow('Payment Date', _formatDateTime(DateTime.now())),
                _buildDetailRow('Status', 'Completed', valueColor: Colors.green),
              ],
            ),
            const SizedBox(height: 32),

            // Important Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Important Information',
                        style: AppTheme.headingSmall.copyWith(
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• Please save this receipt for your records\n'
                    '• Check your email for tournament updates\n'
                    '• Arrive at the venue 30 minutes before your match\n'
                    '• Bring valid ID and team roster\n'
                    '• Contact organizers for any questions',
                    style: AppTheme.bodySmall.copyWith(
                      color: Colors.blue.shade600,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const TournamentListScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: AppTheme.primaryAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Tournaments',
                      style: AppTheme.buttonText.copyWith(
                        color: AppTheme.primaryAccent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Go to Home',
                      style: AppTheme.buttonText.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
          title,
          style: AppTheme.headingSmall,
        ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}