import 'package:flutter/material.dart';
import 'package:player_connect/data/models/ai_recommendation_model.dart';
import 'package:player_connect/data/models/booking_model.dart';
import 'package:player_connect/data/models/open_match_model.dart';
import 'package:player_connect/core/services/ai_recommendation_service.dart';
import 'package:player_connect/core/di/injection.dart';
import 'package:player_connect/presentation/widgets/ai_recommendation/recommendation_modal.dart';
import 'package:player_connect/presentation/widgets/ai_recommendation/create_open_match_modal.dart';

class FindTeammatesPrompt extends StatefulWidget {
  final String bookingId;
  final VoidCallback? onCreateOpenMatch;
  final VoidCallback? onOpenMatchCreated;
  final int? recommendedCount;
  final bool isLoadingRecommendations;
  final bool hasOpenMatch;
  final String? openMatchId;
  final List<dynamic> recommendedPlayers;

  const FindTeammatesPrompt({
    Key? key,
    required this.bookingId,
    this.onCreateOpenMatch,
    this.onOpenMatchCreated,
    this.recommendedCount,
    this.isLoadingRecommendations = false,
    this.hasOpenMatch = false,
    this.openMatchId,
    this.recommendedPlayers = const [],
  }) : super(key: key);

  @override
  State<FindTeammatesPrompt> createState() => _FindTeammatesPromptState();
}

class _FindTeammatesPromptState extends State<FindTeammatesPrompt> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  bool _isLoadingRecommendations = false;

  String _getPromptText() {
    if (widget.isLoadingRecommendations) {
      return 'Đang tìm kiếm người chơi...';
    }

    // Check if we have recommendations data loaded
    if (widget.recommendedPlayers.isNotEmpty) {
      return 'AI đã tìm thấy ${widget.recommendedPlayers.length} người chơi phù hợp. Mời họ ngay!';
    }

    // If recommendedPlayers is empty but we have a count, use it (like FE does)
    if (widget.recommendedCount != null && widget.recommendedCount! > 0) {
      return 'AI đã tìm thấy ${widget.recommendedCount} người chơi phù hợp. Mời họ ngay!';
    }

    return 'Sử dụng AI để tìm những người chơi phù hợp với bạn';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.group_add,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm đồng đội',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getPromptText(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        (_isLoadingRecommendations ||
                            widget.isLoadingRecommendations)
                        ? null
                        : _showRecommendations,
                    icon: _isLoadingRecommendations
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(
                      (_isLoadingRecommendations ||
                              widget.isLoadingRecommendations)
                          ? 'Đang tải...'
                          : 'Xem Gợi Ý & Gửi Lời Mời',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.blue),
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _createOpenMatch,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Tạo Open Match'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
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

  Future<void> _showRecommendations() async {
    setState(() {
      _isLoadingRecommendations = true;
    });

    try {
      // Use bookingId to get recommendations like FE does
      final response = await _aiService.getTeammateRecommendations(
        widget.bookingId,
      );

      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });

        // Show recommendations modal
        showDialog(
          context: context,
          builder: (context) => RecommendationModal(
            recommendations: response.recommendedPlayers,
            bookingId: widget.bookingId,
            onClose: () => Navigator.of(context).pop(),
            hasOpenMatch: widget.hasOpenMatch,
            openMatchId: widget.openMatchId,
            recommendedPlayers: widget.recommendedPlayers,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải gợi ý: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createOpenMatch() async {
    // Show CreateOpenMatchModal
    showDialog(
      context: context,
      builder: (context) => CreateOpenMatchModal(
        bookingDetails: BookingModel(
          id: int.parse(widget.bookingId),
          fieldId: 0,
          fieldName: 'Sân đã đặt',
          startTime: DateTime.now(),
          endTime: DateTime.now().add(Duration(hours: 1)),
          totalPrice: 0.0,
          status: 'confirmed',
          createdAt: DateTime.now(),
        ),
        onSuccess: (openMatch) {
          // Notify parent to refresh booking data
          if (widget.onOpenMatchCreated != null) {
            widget.onOpenMatchCreated!();
          }
        },
      ),
    );
  }

  void _showCreateOpenMatchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo Open Match'),
        content: const Text(
          'Bạn có muốn tạo một Open Match để mời những người chơi khác tham gia không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _createOpenMatchFromBooking();
            },
            child: const Text('Tạo'),
          ),
        ],
      ),
    );
  }

  Future<void> _createOpenMatchFromBooking() async {
    // Check if Open Match already exists for this booking
    if (widget.hasOpenMatch) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Open Match đã tồn tại cho booking này!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    try {
      await _aiService.createOpenMatchFromBooking(
        bookingId: widget.bookingId,
        slotsNeeded: 1, // Default 3 slots needed
        requiredTags: [], // No specific tags required
        sportType: 'BONG_DA',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo Open Match thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        // Notify parent to refresh booking data
        if (widget.onOpenMatchCreated != null) {
          widget.onOpenMatchCreated!();
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Không thể tạo Open Match: ${e.toString()}';

        // Handle specific error cases
        if (e.toString().contains('409') ||
            e.toString().contains('already exists')) {
          errorMessage = 'Open Match đã tồn tại cho booking này!';
        } else if (e.toString().contains('401')) {
          errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
        } else if (e.toString().contains('403')) {
          errorMessage = 'Bạn không có quyền tạo Open Match cho booking này.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }
}
