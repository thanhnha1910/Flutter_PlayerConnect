import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tournament_model.dart';

class TournamentCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback? onTap;
  final bool showRegistrationButton;
  
  const TournamentCard({
    super.key,
    required this.tournament,
    this.onTap,
    this.showRegistrationButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: AppTheme.primaryAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tournament.description,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 16),
              _buildTournamentDetails(),
              if (showRegistrationButton) ...[
                const SizedBox(height: 16),
                _buildRegistrationButton(context),
              ]
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildStatusChip() {
    Color chipColor;
    String statusText;
    
    switch (tournament.status.toLowerCase()) {
      case 'upcoming':
        chipColor = Colors.blue;
        statusText = 'Upcoming';
        break;
      case 'ongoing':
        chipColor = Colors.green;
        statusText = 'Ongoing';
        break;
      case 'completed':
        chipColor = Colors.grey;
        statusText = 'Completed';
        break;
      case 'cancelled':
        chipColor = Colors.red;
        statusText = 'Cancelled';
        break;
      default:
        chipColor = AppTheme.primaryAccent;
        statusText = tournament.status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: chipColor,
        ),
      ),
    );
  }
  
  Widget _buildTournamentDetails() {
    return Column(
      children: [
        Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'Start: ${_formatDate(tournament.startDate)}',
              style: AppTheme.bodySmall,
            ),
            const Spacer(),
            Icon(
              Icons.schedule,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'End: ${_formatDate(tournament.endDate)}',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.people,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              '${tournament.currentTeams}/${tournament.maxTeams} teams',
              style: AppTheme.bodySmall,
            ),
            const Spacer(),
            Icon(
              Icons.attach_money,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              tournament.registrationFee > 0
                  ? '${tournament.registrationFee.toStringAsFixed(0)} VND'
                  : 'Free',
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: tournament.registrationFee > 0
                    ? AppTheme.textPrimary
                    : Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.event_available,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              tournament.registrationDeadline != null
                  ? 'Registration deadline: ${_formatDate(tournament.registrationDeadline!)}'
                  : 'Registration deadline: Not specified',
              style: AppTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildRegistrationButton(BuildContext context) {
    final bool canRegister = tournament.status.toLowerCase() == 'upcoming' &&
        tournament.currentTeams < tournament.maxTeams &&
        tournament.registrationDeadline != null &&
        DateTime.now().isBefore(tournament.registrationDeadline!);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canRegister ? () {
          Navigator.pushNamed(
            context,
            '/tournament-registration',
            arguments: {'tournament': tournament},
          );
        } : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canRegister ? AppTheme.primaryAccent : Colors.grey,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          canRegister ? 'Register Team' : 'Registration Closed',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}