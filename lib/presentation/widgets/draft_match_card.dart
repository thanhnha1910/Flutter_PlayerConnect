import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/draft_match_model.dart';

class DraftMatchCard extends StatelessWidget {
  final DraftMatchModel draftMatch;
  final VoidCallback? onTap;
  final VoidCallback? onExpressInterest;
  final VoidCallback? onWithdrawInterest;
  final Function(int userId)? onApproveUser;
  final Function(int userId)? onRejectUser;
  final VoidCallback? onViewInterestedUsers;
  final VoidCallback? onConvertToMatch;
  final int? currentUserId;
  final bool isProcessing;

  const DraftMatchCard({
    super.key,
    required this.draftMatch,
    this.onTap,
    this.onExpressInterest,
    this.onWithdrawInterest,
    this.onApproveUser,
    this.onRejectUser,
    this.onViewInterestedUsers,
    this.onConvertToMatch,
    this.currentUserId,
    this.isProcessing = false,
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
                  Icon(Icons.schedule, size: 16, color: AppTheme.textSecondary),
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
                  Icon(Icons.people, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: AppTheme.spacingXS),
                  Text(
                    '${draftMatch.approvedSlotsCount}/${draftMatch.slotsNeeded} players',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (draftMatch.pendingUsersCount > 0) ...[
                    const SizedBox(width: AppTheme.spacingS),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusS),
                      ),
                      child: Text(
                        '${draftMatch.pendingUsersCount} pending',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(Icons.star, size: 16, color: AppTheme.textSecondary),
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
                    backgroundColor: _getSportColor().withOpacity(0.2),
                    child: draftMatch.creatorAvatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              draftMatch.creatorAvatarUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to text avatar on error (including CORS)
                                return Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _getSportColor().withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      draftMatch.creatorUserName.isNotEmpty
                                          ? draftMatch.creatorUserName[0].toUpperCase()
                                          : 'U',
                                      style: AppTheme.bodySmall.copyWith(
                                        color: _getSportColor(),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                        : Text(
                            draftMatch.creatorUserName.isNotEmpty
                                ? draftMatch.creatorUserName[0].toUpperCase()
                                : 'U',
                            style: AppTheme.bodySmall.copyWith(
                              color: _getSportColor(),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Expanded(
                    child: Text(
                      'Created by ${draftMatch.creatorUserName}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  if (_isCreator()) ...[
                    if (draftMatch.pendingUsersCount > 0)
                      TextButton(
                        onPressed: onViewInterestedUsers,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                        ),
                        child: Text('Review (${draftMatch.pendingUsersCount})'),
                      ),
                    if (_canConvertToMatch())
                      TextButton(
                        onPressed: onConvertToMatch,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.sports_soccer, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                            const Text('Chuyển thành trận đấu thật'),
                          ],
                        ),
                      ),
                  ] else ...[                    // Logic tương tự FE React:
                    // canJoin = !isCreator && !isInterested && match.status === 'RECRUITING'
                    // canLeave = !isCreator && isInterested && userStatus === 'APPROVED'
                    // isPending = !isCreator && (isInterested && userStatus === 'PENDING')
                    // isProcessing = đang xử lý request
                    
                    if (isProcessing)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          border: Border.all(color: Colors.blue.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đang xử lý...',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_isPending())
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Đang chờ duyệt',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (_canLeave())
                      TextButton(
                        onPressed: isProcessing ? null : onWithdrawInterest,
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.errorColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                          side: BorderSide(color: AppTheme.errorColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_remove, size: 16),
                            const SizedBox(width: 4),
                            const Text('Rút Khỏi Kèo'),
                          ],
                        ),
                      )
                    else if (_canJoin())
                      TextButton(
                        onPressed: isProcessing ? null : onExpressInterest,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: isProcessing ? Colors.grey : Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person_add, size: 16, color: Colors.white),
                            const SizedBox(width: 4)
                           
                          ],
                        ),
                      )
                    else if (draftMatch.status == 'FULL')
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                        child: Text(
                          'Kèo đã đủ người',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.errorColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
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

  bool _isCreator() {
    if (currentUserId == null) return false;
    return currentUserId == draftMatch.creatorUserId;
  }

  String _formatDateTime(DateTime dateTime) {
    // Format like FE: "DD/MM/YYYY HH:mm"
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
  }

  // Helper methods tương tự logic FE React
  bool _canJoin() {
    // Ẩn nút Join để tránh hiển thị không nhất quán
    return false;
  }

  bool _canLeave() {
    return !_isCreator() && 
           (draftMatch.currentUserInterested ?? false) && 
           draftMatch.currentUserStatus == 'APPROVED';
  }

  bool _isPending() {
    return !_isCreator() && 
           (draftMatch.currentUserInterested ?? false) && 
           draftMatch.currentUserStatus == 'PENDING';
  }

  bool _isMatchFull() {
    return draftMatch.approvedUsersCount >= draftMatch.slotsNeeded;
  }

  bool _canConvertToMatch() {
    return _isCreator() && _isMatchFull() && (draftMatch.status == 'RECRUITING' || draftMatch.status == 'FULL');
  }
}
