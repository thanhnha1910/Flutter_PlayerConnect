import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/draft_match_model.dart';
import '../../bloc/draft_match/draft_match_bloc.dart';
import '../../bloc/draft_match/draft_match_event.dart';
import '../../bloc/draft_match/draft_match_state.dart';

class CreateDraftMatchScreen extends StatefulWidget {
  const CreateDraftMatchScreen({super.key});

  @override
  State<CreateDraftMatchScreen> createState() => _CreateDraftMatchScreenState();
}

class _CreateDraftMatchScreenState extends State<CreateDraftMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _slotsController = TextEditingController(text: '1');
  final _tagsController = TextEditingController();
  
  String _selectedSport = '';
  String _selectedSkillLevel = 'ANY';
  DateTime _selectedStartTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _selectedEndTime = DateTime.now().add(const Duration(hours: 3));
  List<String> _requiredTags = [];
  
  // Validation and UI state
  Map<String, String> _errors = {};
  String _timeSuggestion = '';
  bool _isLoading = false;
  
  final List<Map<String, String>> _sportTypes = [
    {'value': 'BONG_DA', 'label': 'Bóng đá'},
    {'value': 'BONG_RO', 'label': 'Bóng rổ'},
    {'value': 'CAU_LONG', 'label': 'Cầu lông'},
    {'value': 'TENNIS', 'label': 'Tennis'},
    {'value': 'BONG_BAN', 'label': 'Bóng bàn'},
    {'value': 'BONG_CHUYEN', 'label': 'Bóng chuyền'},
  ];
  
  final List<Map<String, String>> _skillLevels = [
    {'value': 'ANY', 'label': 'Tất cả trình độ'},
    {'value': 'BEGINNER', 'label': 'Mới bắt đầu'},
    {'value': 'INTERMEDIATE', 'label': 'Trung bình'},
    {'value': 'ADVANCED', 'label': 'Khá giỏi'},
    {'value': 'EXPERT', 'label': 'Chuyên nghiệp'},
  ];

  @override
  void dispose() {
    _locationController.dispose();
    _slotsController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DraftMatchBloc, DraftMatchState>(
      listener: (context, state) {
        if (state is DraftMatchCreated) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Tạo kèo thành công! Mọi người sẽ sớm tham gia.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is DraftMatchError) {
          setState(() {
            _isLoading = false;
          });
          
          String errorMessage = 'Có lỗi xảy ra khi tạo kèo';
          
          if (state.message.contains('400')) {
            errorMessage = 'Thông tin không hợp lệ. Vui lòng kiểm tra lại.';
          } else if (state.message.contains('401')) {
            errorMessage = 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
          } else if (state.message.contains('500')) {
            errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
          } else if (state.message.contains('network') || state.message.contains('connection')) {
            errorMessage = 'Lỗi kết nối. Vui lòng kiểm tra internet và thử lại.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Thử lại',
                textColor: Colors.white,
                onPressed: () {
                  _createDraftMatch();
                },
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Tạo Kèo Tìm Người',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: AppTheme.primaryAccent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: BlocBuilder<DraftMatchBloc, DraftMatchState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSportTypeSection(),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildLocationSection(),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTimeSection(),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildSlotsSection(),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildSkillLevelSection(),
                    const SizedBox(height: AppTheme.spacingL),
                    _buildTagsSection(),
                    const SizedBox(height: AppTheme.spacingXL),
                    _buildCreateButton(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSportTypeSection() {
    final hasError = _errors.containsKey('sportType');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Môn thể thao *',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : AppTheme.borderColor,
              width: hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSport.isEmpty ? null : _selectedSport,
              hint: const Text('Chọn môn thể thao'),
              isExpanded: true,
              items: _sportTypes.map((sport) {
                return DropdownMenuItem<String>(
                  value: sport['value'],
                  child: Text(sport['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSport = value!;
                });
                _clearError('sportType');
              },
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            _errors['sportType']!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    final hasError = _errors.containsKey('locationDescription');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Khu vực *',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Nhập khu vực (ví dụ: Quận 1, TP.HCM)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.borderColor,
                width: hasError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.borderColor,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.primaryAccent,
                width: 2,
              ),
            ),
            prefixIcon: const Icon(Icons.location_on),
            errorText: hasError ? _errors['locationDescription'] : null,
          ),
          onChanged: (value) {
            _clearError('locationDescription');
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    final hasStartTimeError = _errors.containsKey('estimatedStartTime');
    final hasEndTimeError = _errors.containsKey('estimatedEndTime');
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thời gian *',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                'Thời gian bắt đầu',
                _selectedStartTime,
                hasStartTimeError,
                (dateTime) {
                  setState(() {
                    _selectedStartTime = dateTime;
                    // Ensure end time is after start time
                    if (_selectedEndTime.isBefore(_selectedStartTime)) {
                      _selectedEndTime = _selectedStartTime.add(const Duration(hours: 2));
                    }
                  });
                  _clearError('estimatedStartTime');
                  _clearError('estimatedEndTime');
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildTimeField(
                'Thời gian kết thúc',
                _selectedEndTime,
                hasEndTimeError,
                (dateTime) {
                  setState(() {
                    _selectedEndTime = dateTime;
                  });
                  _clearError('estimatedEndTime');
                },
              ),
            ),
          ],
        ),
        if (hasStartTimeError) ...[
          const SizedBox(height: 4),
          Text(
            _errors['estimatedStartTime']!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        if (hasEndTimeError) ...[
          const SizedBox(height: 4),
          Text(
            _errors['estimatedEndTime']!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
        if (_timeSuggestion.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              _timeSuggestion,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeField(String label, DateTime selectedTime, bool hasError, Function(DateTime) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.spacingS),
        InkWell(
          onTap: () => _selectDateTime(selectedTime, onChanged),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasError ? Colors.red : AppTheme.borderColor,
                width: hasError ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule, 
                  color: hasError ? Colors.red : AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '${selectedTime.day}/${selectedTime.month}/${selectedTime.year} ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.bodyMedium.copyWith(
                      color: hasError ? Colors.red : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSlotsSection() {
    final hasError = _errors.containsKey('slotsNeeded');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Số người cần tìm *',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _slotsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Nhập số người cần tìm (1-50)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.borderColor,
                width: hasError ? 2 : 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.borderColor,
                width: hasError ? 2 : 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              borderSide: BorderSide(
                color: hasError ? Colors.red : AppTheme.primaryAccent,
                width: 2,
              ),
            ),
            prefixIcon: const Icon(Icons.people),
            errorText: hasError ? _errors['slotsNeeded'] : null,
          ),
          onChanged: (value) {
            _clearError('slotsNeeded');
          },
        ),
      ],
    );
  }

  Widget _buildSkillLevelSection() {
    final hasError = _errors.containsKey('skillLevel');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trình độ yêu cầu *',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasError ? Colors.red : AppTheme.borderColor,
              width: hasError ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSkillLevel,
              isExpanded: true,
              items: _skillLevels.map((level) {
                return DropdownMenuItem<String>(
                  value: level['value'],
                  child: Text(level['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSkillLevel = value!;
                });
                _clearError('skillLevel');
              },
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            _errors['skillLevel']!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Tags (Optional)',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _tagsController,
          decoration: InputDecoration(
            hintText: 'Enter tags separated by commas',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            prefixIcon: const Icon(Icons.tag),
          ),
          onChanged: (value) {
            setState(() {
              _requiredTags = value
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();
            });
          },
        ),
        if (_requiredTags.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingM),
          Wrap(
            spacing: AppTheme.spacingS,
            children: _requiredTags.map((tag) {
              return Chip(
                label: Text(tag),
                backgroundColor: AppTheme.primaryAccent.withOpacity(0.1),
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _requiredTags.remove(tag);
                    _tagsController.text = _requiredTags.join(', ');
                  });
                },
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCreateButton(DraftMatchState state) {
    final isLoading = state is DraftMatchLoading || _isLoading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _createDraftMatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading ? Colors.grey : AppTheme.primaryAccent,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Đang tạo kèo...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : const Text(
                'Đăng Kèo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Future<void> _selectDateTime(DateTime initialDateTime, Function(DateTime) onChanged) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDateTime),
      );
      
      if (time != null) {
        final dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        onChanged(dateTime);
      }
    }
  }

  bool _validateForm() {
    final newErrors = <String, String>{};
    
    // Required field validations
    if (_selectedSport.isEmpty) {
      newErrors['sportType'] = 'Vui lòng chọn môn thể thao';
    }
    
    if (_locationController.text.trim().isEmpty) {
      newErrors['locationDescription'] = 'Vui lòng nhập khu vực';
    }
    
    // Skill level validation
    if (_selectedSkillLevel.isEmpty) {
      newErrors['skillLevel'] = 'Vui lòng chọn trình độ';
    } else {
      const validSkillLevels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'EXPERT', 'ANY'];
      if (!validSkillLevels.contains(_selectedSkillLevel)) {
        newErrors['skillLevel'] = 'Trình độ không hợp lệ';
      }
    }
    
    // Slots validation
    final slotsText = _slotsController.text.trim();
    if (slotsText.isEmpty) {
      newErrors['slotsNeeded'] = 'Vui lòng nhập số người cần tìm';
    } else {
      final slots = int.tryParse(slotsText);
      if (slots == null) {
        newErrors['slotsNeeded'] = 'Số người cần tìm phải là số nguyên';
      } else if (slots < 1) {
        newErrors['slotsNeeded'] = 'Số người cần tìm phải lớn hơn 0';
      } else if (slots > 50) {
        newErrors['slotsNeeded'] = 'Số người cần tìm không được vượt quá 50';
      }
    }
    
    // Enhanced DateTime validation
    final now = DateTime.now();
    
    // Start time validation
    if (_selectedStartTime.isBefore(now) || _selectedStartTime.isAtSameMomentAs(now)) {
      newErrors['estimatedStartTime'] = 'Thời gian bắt đầu phải trong tương lai';
    } else {
      final timeDiffMinutes = _selectedStartTime.difference(now).inMinutes;
      if (timeDiffMinutes < 30) {
        newErrors['estimatedStartTime'] = 'Thời gian bắt đầu nên cách ít nhất 30 phút để mọi người có thời gian chuẩn bị';
      }
      
      final timeDiffDays = timeDiffMinutes / (60 * 24);
      if (timeDiffDays > 30) {
        newErrors['estimatedStartTime'] = 'Thời gian bắt đầu không nên quá xa (tối đa 30 ngày) để đảm bảo tính khả thi';
      }
    }
    
    // End time validation
    if (_selectedEndTime.isBefore(now) || _selectedEndTime.isAtSameMomentAs(now)) {
      newErrors['estimatedEndTime'] = 'Thời gian kết thúc phải trong tương lai';
    }
    
    // Time range validation
    if (_selectedEndTime.isBefore(_selectedStartTime) || _selectedEndTime.isAtSameMomentAs(_selectedStartTime)) {
      newErrors['estimatedEndTime'] = 'Thời gian kết thúc phải sau thời gian bắt đầu';
    } else {
      final durationMinutes = _selectedEndTime.difference(_selectedStartTime).inMinutes;
      final durationHours = durationMinutes / 60;
      
      if (durationMinutes < 30) {
        newErrors['estimatedEndTime'] = 'Thời gian chơi quá ngắn! Nên ít nhất 30 phút để có trận đấu chất lượng';
      } else if (durationHours > 4) {
        newErrors['estimatedEndTime'] = 'Thời gian chơi quá dài! Trận đấu không nên vượt quá 4 tiếng để đảm bảo chất lượng và sức khỏe';
      }
      
      // Generate smart suggestions
      _generateTimeSuggestion(durationMinutes, durationHours);
      
      // Check if match spans multiple days
      final startDate = DateTime(_selectedStartTime.year, _selectedStartTime.month, _selectedStartTime.day);
      final endDate = DateTime(_selectedEndTime.year, _selectedEndTime.month, _selectedEndTime.day);
      final daysDiff = endDate.difference(startDate).inDays;
      
      if (daysDiff > 0) {
        newErrors['estimatedEndTime'] = 'Trận đấu không nên kéo dài qua nhiều ngày. Vui lòng tạo các kèo riêng biệt cho từng ngày';
      }
    }
    
    setState(() {
      _errors = newErrors;
    });
    
    return newErrors.isEmpty;
  }
  
  void _generateTimeSuggestion(int durationMinutes, double durationHours) {
    String suggestion = '';
    
    if (durationMinutes >= 30 && durationMinutes < 60) {
      suggestion = '💡 Gợi ý: Trận đấu ngắn phù hợp cho khởi động hoặc giao hữu nhanh';
    } else if (durationHours >= 1 && durationHours <= 4) {
      suggestion = '✅ Thời gian lý tưởng cho một trận đấu chất lượng';
    }
    
    // Additional suggestions based on timing
    final startHour = _selectedStartTime.hour;
    final endHour = _selectedEndTime.hour;
    
    if (startHour < 6 && suggestion.isEmpty) {
      suggestion = '🌅 Lưu ý: Trận đấu sáng sớm - đảm bảo mọi người có thể tham gia';
    } else if ((endHour >= 22 || (endHour >= 0 && endHour < 6)) && suggestion.isEmpty) {
      suggestion = '🌙 Lưu ý: Trận đấu muộn - cân nhắc về an toàn và tiếng ồn';
    } else if (((startHour >= 6 && startHour <= 9) || (startHour >= 17 && startHour <= 20)) && suggestion.isEmpty) {
      suggestion = '🔥 Giờ vàng: Thời gian này thường có nhiều người tham gia';
    }
    
    setState(() {
      _timeSuggestion = suggestion;
    });
  }
  
  void _clearError(String field) {
    if (_errors.containsKey(field)) {
      setState(() {
        _errors.remove(field);
      });
    }
  }
  
  void _createDraftMatch() {
    if (_validateForm()) {
      setState(() {
        _isLoading = true;
      });
      
      final request = CreateDraftMatchRequest(
        sportType: _selectedSport,
        locationDescription: _locationController.text.trim(),
        estimatedStartTime: _selectedStartTime,
        estimatedEndTime: _selectedEndTime,
        slotsNeeded: int.parse(_slotsController.text),
        skillLevel: _selectedSkillLevel,
        requiredTags: _requiredTags,
      );
      
      context.read<DraftMatchBloc>().add(CreateDraftMatch(request));
    }
  }
}