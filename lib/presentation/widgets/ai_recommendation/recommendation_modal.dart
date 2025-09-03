import 'package:flutter/material.dart';
import 'package:player_connect/data/models/ai_recommendation_model.dart';
import 'package:player_connect/core/services/ai_recommendation_service.dart';
import 'package:player_connect/core/di/injection.dart';

class RecommendationModal extends StatefulWidget {
  final List<RecommendedPlayerModel> recommendations;
  final String bookingId;
  final VoidCallback onClose;

  const RecommendationModal({
    Key? key,
    required this.recommendations,
    required this.bookingId,
    required this.onClose,
  }) : super(key: key);

  @override
  State<RecommendationModal> createState() => _RecommendationModalState();
}

class _RecommendationModalState extends State<RecommendationModal> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  final Set<String> _sentInvitations = {};
  bool _isLoading = false;

  Future<void> _sendInvitation(RecommendedPlayerModel player) async {
    if (_sentInvitations.contains(player.id)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _aiService.sendPlayerInvitation(
        bookingId: widget.bookingId,
        inviteeId: player.id,
        message: 'Bạn có muốn tham gia trận đấu cùng tôi không?',
      );

      setState(() {
        _sentInvitations.add(player.id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi lời mời đến ${player.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi lời mời: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gợi ý đồng đội',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: widget.onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.recommendations.isEmpty)
              const Expanded(
                child: Center(
                  child: Text(
                    'Không có gợi ý nào',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: widget.recommendations.length,
                  itemBuilder: (context, index) {
                    final player = widget.recommendations[index];
                    final isInvited = _sentInvitations.contains(player.id);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: player.avatar != null
                                      ? NetworkImage(player.avatar!)
                                      : null,
                                  child: player.avatar == null
                                      ? Text(
                                          player.name.isNotEmpty
                                              ? player.name[0].toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (player.skillLevel != null)
                                        Text(
                                          'Trình độ: ${player.skillLevel}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      Text(
                                        'Độ phù hợp: ${(player.compatibilityScore * 100).toInt()}%',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.blue[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (player.tags.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 4,
                                children: player.tags.map((tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                                  backgroundColor: Colors.blue[100],
                                )).toList(),
                              ),
                            ],
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isInvited || _isLoading
                                    ? null
                                    : () => _sendInvitation(player),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInvited
                                      ? Colors.grey
                                      : Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
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
                                        isInvited ? 'Đã gửi lời mời' : 'Gửi lời mời',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}