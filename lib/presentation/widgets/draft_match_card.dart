import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/draft_match_model.dart';

class DraftMatchCard extends StatelessWidget {
  final DraftMatchModel draftMatch;
  final VoidCallback? onTap;
  final VoidCallback? onExpressInterest;
  final VoidCallback? onWithdrawInterest;

  const DraftMatchCard({
    super.key,
    required this.draftMatch,
    this.onTap,
    this.onExpressInterest,
    this.onWithdrawInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getSportColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      draftMatch.sportTypeDisplay,
                      style: AppTheme.bodySmall.copyWith(
                        color: _getSportColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      _getStatusText(),
                      style: AppTheme.bodySmall.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),
              Text(
                draftMatch.locationDescription,
                style: AppTheme.headingSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    _formatDateTime(draftMatch.estimatedStartTime),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingS),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    '${draftMatch.approvedSlotsCount}/${draftMatch.slotsNeeded} players',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.star,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    draftMatch.skillLevelDisplay,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              if (draftMatch.requiredTags.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingS),
                Wrap(
                  spacing: AppTheme.spacingXS,
                  children: draftMatch.requiredTags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        tag,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: AppTheme.spacingM),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: draftMatch.creator.profilePicture != null
                        ? NetworkImage(draftMatch.creator.profilePicture!)
                        : null,
                    child: draftMatch.creator.profilePicture == null
                        ? Text(
                            draftMatch.creator.fullName.isNotEmpty
                                ? draftMatch.creator.fullName[0].toUpperCase()
                                : 'U',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Created by ${draftMatch.creator.fullName}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  if (draftMatch.hasUserExpressedInterest == true)
                    TextButton(
                      onPressed: onWithdrawInterest,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                        ),
                      ),
                      child: const Text('Withdraw'),
                    )
                  else if (draftMatch.isCreatedByUser != true)
                    TextButton(
                      onPressed: onExpressInterest,
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                        ),
                      ),
                      child: const Text('Join'),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getSportColor() {
    switch (draftMatch.sportType) {
      case 'BONG_DA':
        return Colors.green;
      case 'BONG_RO':
        return Colors.orange;
      case 'CAU_LONG':
        return Colors.blue;
      case 'TENNIS':
        return Colors.purple;
      case 'BONG_BAN':
        return Colors.red;
      case 'BONG_CHUYEN':
        return Colors.teal;
      default:
        return AppTheme.primaryAccent;
    }
  }

  Color _getStatusColor() {
    switch (draftMatch.status) {
      case 'ACTIVE':
        return Colors.green;
      case 'FULL':
        return Colors.orange;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _getStatusText() {
    switch (draftMatch.status) {
      case 'ACTIVE':
        return 'Active';
      case 'FULL':
        return 'Full';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return draftMatch.status;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${dateTime.minute.toString().padLeft(2, '0')}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Now';
    }
  }
}