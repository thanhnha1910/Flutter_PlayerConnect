import 'package:flutter/material.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/unified_invitation_model.dart';
import '../../data/models/open_match_join_request_model.dart';

class InvitationCard extends StatelessWidget {
  final InvitationModel? invitation;
  final UnifiedInvitationModel? unifiedInvitation;
  final DraftMatchRequestModel? draftMatchRequest;
  final OpenMatchJoinRequestModel? openMatchJoinRequest;
  final bool isReceived;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onTap;
  final int? currentUserId;

  const InvitationCard({
    Key? key,
    this.invitation,
    this.unifiedInvitation,
    this.draftMatchRequest,
    this.openMatchJoinRequest,
    required this.isReceived,
    this.onAccept,
    this.onReject,
    this.onTap,
    this.currentUserId,
  }) : assert(
         invitation != null ||
             unifiedInvitation != null ||
             draftMatchRequest != null ||
             openMatchJoinRequest != null,
       ),
       super(key: key);

  String getDisplayText() {
    if (invitation != null) {
      if (isReceived) {
        return '${invitation!.sender.fullName} đã mời bạn tham gia trận đấu';
      } else {
        return 'Bạn đã mời ${invitation!.receiver?.fullName ?? "người chơi"} tham gia trận đấu';
      }
    }
    
    if (unifiedInvitation != null) {
      if (isReceived) {
        return '${unifiedInvitation!.inviterName ?? "Người chơi"} đã mời bạn tham gia trận đấu';
      } else {
        return 'Bạn đã mời ${unifiedInvitation!.receiverName ?? "người chơi"} tham gia trận đấu';
      }
    }
    
    if (draftMatchRequest != null) {
      if (isReceived) {
        return '${draftMatchRequest!.user.fullName} đã yêu cầu tham gia trận đấu của bạn';
      } else {
        return 'Bạn đã yêu cầu tham gia trận đấu';
      }
    }
    
    if (openMatchJoinRequest != null) {
      if (isReceived) {
        return '${openMatchJoinRequest!.user.fullName} đã yêu cầu tham gia trận đấu mở của bạn';
      } else {
        return 'Bạn đã yêu cầu tham gia trận đấu mở';
      }
    }
    
    return 'Thông báo';
  }

  String getMatchDetails() {
    String details = '';
    
    if (invitation != null && invitation!.draftMatch != null) {
      final match = invitation!.draftMatch!;
      details += 'Môn thể thao: ${match.sportType}\n';
      details += 'Địa điểm: ${match.locationDescription}\n';
      details += 'Thời gian: ${_formatDateTime(match.estimatedStartTime)}';
    }
    
    if (unifiedInvitation != null) {
      if (unifiedInvitation!.sportType != null) details += 'Môn thể thao: ${unifiedInvitation!.sportType}\n';
      if (unifiedInvitation!.fieldName != null) details += 'Địa điểm: ${unifiedInvitation!.fieldName}\n';
      if (unifiedInvitation!.matchDateTime != null) {
        details += 'Thời gian: ${unifiedInvitation!.matchDateTime}';
      }
    }
    
    if (draftMatchRequest != null && draftMatchRequest!.draftMatch != null) {
      final match = draftMatchRequest!.draftMatch!;
      details += 'Môn thể thao: ${match.sportType}\n';
      details += 'Địa điểm: ${match.locationDescription}\n';
      details += 'Thời gian: ${_formatDateTime(match.estimatedStartTime)}';
    }
    
    if (openMatchJoinRequest != null) {
      final match = openMatchJoinRequest!.openMatch;
      details += 'Môn thể thao: ${match.gameType}\n';
      details += 'Địa điểm: ${match.locationName}\n';
      details += 'Thời gian: ${_formatDateTime(match.startTime)}';
    }
    
    return details;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  IconData getInvitationIcon() {
    if (invitation != null || unifiedInvitation != null) {
      return Icons.sports_tennis;
    }
    if (draftMatchRequest != null || openMatchJoinRequest != null) {
      return Icons.group_add;
    }
    return Icons.notifications;
  }

  @override
  Widget build(BuildContext context) {
    final isInvitation = invitation != null;
    final isUnifiedInvitation = unifiedInvitation != null;
    final isDraftMatchRequest = draftMatchRequest != null;
    final isOpenMatchJoinRequest = openMatchJoinRequest != null;

    final senderUser = isUnifiedInvitation
        ? null // UnifiedInvitation doesn't use senderUser
        : isInvitation
        ? invitation!.sender
        : isDraftMatchRequest
        ? draftMatchRequest!.user
        : openMatchJoinRequest!.user;

    final senderName = isUnifiedInvitation
        ? (unifiedInvitation!.inviterName ?? 'Unknown')
        : (senderUser?.fullName ?? 'Unknown');

    final senderUsername = isUnifiedInvitation
        ? '@${unifiedInvitation!.inviterName}' // Use inviterName as fallback
        : senderUser?.username != null
        ? '@${senderUser!.username}'
        : '@unknown';

    final senderProfilePicture = isUnifiedInvitation
        ? null // UnifiedInvitationModel doesn't have profile picture
        : senderUser?.profilePicture;

    final status = isInvitation
        ? invitation!.status
        : isUnifiedInvitation
        ? unifiedInvitation!.status
        : isDraftMatchRequest
        ? draftMatchRequest!.status
        : openMatchJoinRequest!.status;

    final createdAt = isInvitation
        ? invitation!.createdAt
        : isUnifiedInvitation
        ? unifiedInvitation!.createdAt
        : isDraftMatchRequest
        ? draftMatchRequest!.createdAt
        : openMatchJoinRequest!.createdAt;

    final isPending = status == 'PENDING';
    
    final displayText = getDisplayText();
    final matchDetails = getMatchDetails();
    final invitationIcon = getInvitationIcon();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    backgroundImage: senderProfilePicture != null
                        ? NetworkImage(senderProfilePicture!)
                        : null,
                    child: senderProfilePicture == null
                        ? Icon(
                            invitationIcon,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          )
                        : null,
                  ),
                   const SizedBox(width: 12),

                  // Sender info and status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          senderName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayText,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        if (matchDetails.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              matchDetails,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              senderUsername,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey[600]),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _formatRelativeTime(createdAt),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  _buildStatusBadge(status, context),
                ],
              ),

              // Message if exists
              if (isInvitation && invitation!.message != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    invitation!.message!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],

              if (draftMatchRequest != null &&
                  draftMatchRequest!.message != null) ...<Widget>[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    draftMatchRequest!.message!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],

              // Action buttons for pending invitations/requests
              if (isPending &&
                  isReceived &&
                  (onAccept != null || onReject != null)) ...<Widget>[
                const SizedBox(height: 16),
                Row(
                  children: [
                    if (onReject != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onReject,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Từ chối'),
                        ),
                      ),
                    if (onReject != null && onAccept != null)
                      const SizedBox(width: 12),
                    if (onAccept != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: onAccept,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Chấp nhận'),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, BuildContext context) {
    Color color;
    String text;

    switch (status.toUpperCase()) {
      case 'PENDING':
        color = Colors.orange;
        text = 'Chờ xử lý';
        break;
      case 'ACCEPTED':
        color = Colors.green;
        text = 'Đã chấp nhận';
        break;
      case 'REJECTED':
        color = Colors.red;
        text = 'Đã từ chối';
        break;
      default:
        color = Colors.grey;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'ACCEPTED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}
