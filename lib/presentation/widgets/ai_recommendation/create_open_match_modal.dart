import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/di/injection.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/models/open_match_model.dart';
import '../../../core/services/ai_recommendation_service.dart';

class CreateOpenMatchModal extends StatefulWidget {
  final BookingModel bookingDetails;
  final Function(OpenMatchModel)? onSuccess;

  const CreateOpenMatchModal({
    Key? key,
    required this.bookingDetails,
    this.onSuccess,
  }) : super(key: key);

  @override
  State<CreateOpenMatchModal> createState() => _CreateOpenMatchModalState();
}

class _CreateOpenMatchModalState extends State<CreateOpenMatchModal> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  final TextEditingController _playersNeededController = TextEditingController(text: '1');
  
  int _playersNeeded = 1;
  List<String> _selectedTags = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSuccess = false;

  static const List<String> _popularTags = [
    'Thủ môn',
    'Hậu vệ',
    'Tiền vệ',
    'Tiền đạo',
    'Chơi phòng ngự',
    'Chơi tấn công',
    'Kỹ thuật tốt',
    'Thể lực tốt',
    'Chơi fair-play',
    'Kinh nghiệm',
    'Mới học',
    'Chơi cuối tuần',
    'Chơi buổi tối',
    'Chơi sáng sớm',
    'Thích đá 11 người',
    'Thích đá 7 người',
    'Thích đá 5 người',
    'Point Guard',
    'Shooting Guard',
    'Chủ công',
    'Phụ công',
    'Libero',
    'Đánh đơn',
    'Đánh đôi',
    'Smash mạnh',
  ];

  @override
  void dispose() {
    _playersNeededController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_playersNeeded < 1 || _playersNeeded > 20) {
      setState(() {
        _errorMessage = 'Số người cần tìm phải từ 1 đến 20';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create open match using AI service
      final openMatch = await _aiService.createOpenMatchFromBooking(
        bookingId: widget.bookingDetails.id.toString(),
        slotsNeeded: _playersNeeded,
        requiredTags: _selectedTags,
        sportType: 'BONG_DA',
      );

      setState(() {
        _showSuccess = true;
      });

      // Show success for 2 seconds then close
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        widget.onSuccess?.call(openMatch);
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('401')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (error.contains('403')) {
      return 'Bạn không có quyền tạo open match cho booking này.';
    } else if (error.contains('409')) {
      return 'Open match đã tồn tại cho booking này.';
    } else if (error.contains('400')) {
      return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
    } else if (error.contains('500')) {
      return 'Lỗi server. Vui lòng thử lại sau.';
    }
    return 'Không thể tạo open match. Vui lòng thử lại.';
  }

  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else if (_selectedTags.length < 5) {
        _selectedTags.add(tag);
      }
    });
  }

  Widget _buildSuccessView() {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Tạo thành công!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Open match của bạn đã được tạo và sẽ xuất hiện trong danh sách tìm kiếm.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessView();
    }

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(
                  Icons.group,
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Tạo Open Match',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo một open match để tìm kiếm đồng đội cho trận đấu của bạn.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Booking Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(color: Colors.blue.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thông tin đặt sân:',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sân: ${widget.bookingDetails.fieldName ?? 'N/A'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Thời gian: ${widget.bookingDetails.timeRange}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    'Địa điểm: N/A',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Players Needed Input
            const Text(
              'Số người cần tìm',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _playersNeededController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(2),
              ],
              onChanged: (value) {
                setState(() {
                  _playersNeeded = int.tryParse(value) ?? 1;
                });
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '1',
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Nhập số lượng người chơi bạn muốn tìm kiếm (1-20 người)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Tags Selection
            const Text(
              'Yêu cầu kỹ năng/phong cách (tùy chọn)',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _popularTags.map((tag) {
                    final isSelected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      onSelected: (_selectedTags.length < 5 || isSelected) 
                          ? (_) => _toggleTag(tag)
                          : null,
                      selectedColor: Colors.blue.shade100,
                      checkmarkColor: Colors.blue,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Thêm các tag để mô tả loại người chơi bạn đang tìm kiếm (tối đa 5 tags). Để trống nếu không có yêu cầu đặc biệt.',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),

            // Error Message
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading || _playersNeeded < 1 ? null : _handleSubmit,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isLoading ? 'Đang tạo...' : 'Tạo Open Match'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}