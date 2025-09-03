import 'package:flutter/material.dart';
import 'package:player_connect/data/models/ai_recommendation_model.dart';
import 'package:player_connect/core/services/ai_recommendation_service.dart';
import 'package:player_connect/core/di/injection.dart';
import 'package:player_connect/presentation/widgets/ai_recommendation/recommendation_modal.dart';

class FindTeammatesPrompt extends StatefulWidget {
  final String bookingId;
  final VoidCallback? onCreateOpenMatch;

  const FindTeammatesPrompt({
    Key? key,
    required this.bookingId,
    this.onCreateOpenMatch,
  }) : super(key: key);

  @override
  State<FindTeammatesPrompt> createState() => _FindTeammatesPromptState();
}

class _FindTeammatesPromptState extends State<FindTeammatesPrompt> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  bool _isLoadingRecommendations = false;

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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sử dụng AI để tìm những người chơi phù hợp với bạn',
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
                    onPressed: _isLoadingRecommendations ? null : _showRecommendations,
                    icon: _isLoadingRecommendations
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.psychology),
                    label: Text(_isLoadingRecommendations ? 'Đang tải...' : 'Xem Gợi Ý'),
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
      final response = await _aiService.getTeammateRecommendations(widget.bookingId);
      
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

  void _createOpenMatch() {
    if (widget.onCreateOpenMatch != null) {
      widget.onCreateOpenMatch!();
    } else {
      // Default behavior - show dialog to create open match
      _showCreateOpenMatchDialog();
    }
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
    try {
      await _aiService.createOpenMatchFromBooking(
        bookingId: widget.bookingId,
        title: 'Tìm đồng đội',
        description: 'Tìm người chơi cùng',
        maxPlayers: 4,
        pricePerPlayer: 0.0,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo Open Match thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tạo Open Match: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}