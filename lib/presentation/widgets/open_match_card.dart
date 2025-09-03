import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/open_match_model.dart';
import '../../data/models/open_match_join_request_model.dart';
import '../../core/di/injection.dart';
import '../../domain/repositories/invitation_repository.dart';

class OpenMatchCard extends StatefulWidget {
  final OpenMatchModel openMatch;
  final VoidCallback? onTap;
  final VoidCallback? onRefresh;

  const OpenMatchCard({
    super.key,
    required this.openMatch,
    this.onTap,
    this.onRefresh,
  });

  @override
  State<OpenMatchCard> createState() => _OpenMatchCardState();
}

class _OpenMatchCardState extends State<OpenMatchCard> {
  bool _isLoading = false;
  final InvitationRepository _invitationRepository =
      getIt<InvitationRepository>();

  Future<void> _handleSendJoinRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final request = SendOpenMatchJoinRequestModel(
        message: 'Tôi muốn tham gia trận đấu này!',
      );

      final result = await _invitationRepository.sendOpenMatchJoinRequest(
        widget.openMatch.id,
        request,
      );

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi gửi yêu cầu: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã gửi yêu cầu tham gia!'),
                backgroundColor: Colors.green,
              ),
            );
            widget.onRefresh?.call();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi không mong đợi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLeaveMatch() async {
    if (_isLoading) return;

    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rời khỏi trận đấu'),
        content: const Text('Bạn có chắc chắn muốn rời khỏi trận đấu này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rời khỏi'),
          ),
        ],
      ),
    );

    if (shouldLeave != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Note: Leave functionality might need to be implemented differently
      // For now, we'll keep the existing implementation
      // TODO: Implement proper leave workflow through invitation system
      throw UnimplementedError(
        'Leave functionality needs to be implemented through invitation system',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã rời khỏi trận đấu!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRefresh?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi rời khỏi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _getSportColor() {
    switch (widget.openMatch.gameType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Colors.green;
      case 'basketball':
        return Colors.orange;
      case 'tennis':
        return Colors.blue;
      case 'badminton':
        return Colors.purple;
      case 'volleyball':
        return Colors.red;
      default:
        return AppTheme.primaryAccent;
    }
  }

  Color _getCompatibilityColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getCompatibilityLabel(double score) {
    if (score >= 80) return 'Rất phù hợp';
    if (score >= 60) return 'Phù hợp';
    return 'Ít phù hợp';
  }

  String _formatDate(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(dateTime);
  }

  IconData _getSportIcon() {
    switch (widget.openMatch.gameType.toLowerCase()) {
      case 'football':
      case 'soccer':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_tennis;
      case 'volleyball':
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sportColor = _getSportColor();
    final isMatchFull =
        widget.openMatch.currentParticipants >= widget.openMatch.slotsNeeded;
    final spotsLeft =
        widget.openMatch.slotsNeeded - widget.openMatch.currentParticipants;
    final isCreator = widget.openMatch.isCreator;

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: sportColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getSportIcon(), size: 16, color: sportColor),
                        const SizedBox(width: 4),
                        Text(
                          widget.openMatch.gameType,
                          style: AppTheme.bodySmall.copyWith(
                            color: sportColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    decoration: BoxDecoration(
                      color: isMatchFull
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusS),
                    ),
                    child: Text(
                      isMatchFull ? 'Đầy' : '$spotsLeft chỗ trống',
                      style: AppTheme.bodySmall.copyWith(
                        color: isMatchFull ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Title
              Text(
                widget.openMatch.locationName.isNotEmpty
                    ? widget.openMatch.locationName
                    : widget.openMatch.fieldName,
                style: AppTheme.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppTheme.spacingS),

              // AI Compatibility Score
              if (!isCreator && widget.openMatch.compatibilityScore != null)
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                        color: _getCompatibilityColor(
                          widget.openMatch.compatibilityScore!,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getCompatibilityColor(
                            widget.openMatch.compatibilityScore!,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusS),
                        ),
                        child: Text(
                          '${_getCompatibilityLabel(widget.openMatch.compatibilityScore!)} ${widget.openMatch.compatibilityScore!.toStringAsFixed(0)}%',
                          style: AppTheme.bodySmall.copyWith(
                            color: _getCompatibilityColor(
                              widget.openMatch.compatibilityScore!,
                            ),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Required Tags
              if (widget.openMatch.requiredTags.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: AppTheme.spacingS),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Yêu cầu:',
                        style: AppTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.openMatch.requiredTags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacingS,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryAccent.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusS,
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: AppTheme.bodySmall.copyWith(
                                    color: AppTheme.primaryAccent,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),

              // Description
              if (widget.openMatch.description != null &&
                  widget.openMatch.description!.isNotEmpty)
                Text(
                  widget.openMatch.description!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: AppTheme.spacingM),

              // Match Details
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppTheme.primaryAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(widget.openMatch.startTime),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.primaryAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(widget.openMatch.startTime),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingM),
                  Icon(Icons.people, size: 16, color: AppTheme.primaryAccent),
                  const SizedBox(width: 4),
                  Text(
                    'Cần ${widget.openMatch.slotsNeeded - widget.openMatch.currentParticipants} người',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.openMatch.fieldAddress,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Creator Info
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingS),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusS),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage:
                          widget.openMatch.creatorAvatarUrl != null &&
                              widget.openMatch.creatorAvatarUrl!.isNotEmpty
                          ? NetworkImage(widget.openMatch.creatorAvatarUrl!)
                          : null,
                      child:
                          widget.openMatch.creatorAvatarUrl == null ||
                              widget.openMatch.creatorAvatarUrl!.isEmpty
                          ? Text(
                              widget.openMatch.creatorUserName.isNotEmpty
                                  ? widget.openMatch.creatorUserName[0]
                                        .toUpperCase()
                                  : 'U',
                              style: AppTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: AppTheme.spacingS),
                    Text(
                      widget.openMatch.creatorUserName.isNotEmpty
                          ? widget.openMatch.creatorUserName
                          : 'Unknown',
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),

              // Action Button
              _buildActionButton(isMatchFull),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(bool isMatchFull) {
    // If user is the creator, don't show any action button
    if (widget.openMatch.isCreator) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
        decoration: BoxDecoration(
          color: AppTheme.primaryAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusS),
        ),
        child: Text(
          'Bạn là người tạo',
          textAlign: TextAlign.center,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryAccent,
          ),
        ),
      );
    }

    // If match is full, show disabled button
    if (isMatchFull) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.textSecondary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusS),
            ),
          ),
          child: Text(
            'Đã đầy',
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Show button based on join status
    switch (widget.openMatch.currentUserJoinStatus) {
      case JoinStatus.NOT_JOINED:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendJoinRequest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Gửi yêu cầu tham gia',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );

      case JoinStatus.REQUEST_PENDING:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_empty, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              Text(
                'Đang chờ duyệt',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        );

      case JoinStatus.JOINED:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLeaveMatch,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Rời khỏi',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
    }
  }
}
