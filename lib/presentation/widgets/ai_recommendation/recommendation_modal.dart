import 'package:flutter/material.dart';
import 'package:player_connect/data/models/ai_recommendation_model.dart';
import 'package:player_connect/core/services/ai_recommendation_service.dart';
import 'package:player_connect/core/di/injection.dart';

class RecommendationModal extends StatefulWidget {
  final List<RecommendedPlayerModel> recommendations;
  final String bookingId;
  final VoidCallback onClose;
  final bool hasOpenMatch;
  final List<dynamic> recommendedPlayers;
  final String? openMatchId;

  const RecommendationModal({
    Key? key,
    required this.recommendations,
    required this.bookingId,
    required this.onClose,
    this.hasOpenMatch = false,
    this.recommendedPlayers = const [],
    this.openMatchId,
  }) : super(key: key);

  @override
  State<RecommendationModal> createState() => _RecommendationModalState();
}

class _RecommendationModalState extends State<RecommendationModal> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  final Set<String> _sentInvitations = {};
  bool _isLoading = false;

  List<dynamic> get _recommendations => widget.recommendedPlayers;

  Future<void> _sendInvitation(RecommendedPlayerModel player) async {
    if (_sentInvitations.contains(player.id)) return;

    // Check if openMatchId is available
    if (widget.openMatchId == null || widget.openMatchId!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lỗi: Bạn cần tạo trận đấu mở trước khi mời người chơi'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _aiService.sendInvitation(
        inviteeId: player.id,
        openMatchId: widget.openMatchId!,
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

  /// Format compatibility score with validation similar to React's convertCompatibilityScore
  int _formatCompatibilityScore(double rawScore) {
    // Clamp score between 0 and 1, then convert to percentage
    final clampedScore = rawScore.clamp(0.0, 1.0);
    return (clampedScore * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(
          maxWidth: 400,
          maxHeight: 600,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gợi ý đồng đội',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!widget.hasOpenMatch)
                        Container(
                          margin: const EdgeInsets.only(top: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Bạn cần tạo Open Match trước khi gửi lời mời',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
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
                                const SizedBox(width: 8),
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
                                      if (player.compatibilityScore != null && player.compatibilityScore! >= 0)
                                        Text(
                                          'Độ phù hợp: ${_formatCompatibilityScore(player.compatibilityScore!)}%',
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
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isInvited || _isLoading || !widget.hasOpenMatch
                                    ? null
                                    : () => _sendInvitation(player),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isInvited || !widget.hasOpenMatch
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
                                        isInvited 
                                            ? 'Đã gửi lời mời' 
                                            : !widget.hasOpenMatch
                                                ? 'Cần tạo Open Match'
                                                : 'Gửi lời mời',
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