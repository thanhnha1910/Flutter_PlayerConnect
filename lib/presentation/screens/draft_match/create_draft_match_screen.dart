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
  final _slotsController = TextEditingController();
  final _tagsController = TextEditingController();
  
  String _selectedSport = 'BONG_DA';
  String _selectedSkillLevel = 'ANY';
  DateTime _selectedStartTime = DateTime.now().add(const Duration(hours: 1));
  DateTime _selectedEndTime = DateTime.now().add(const Duration(hours: 3));
  List<String> _requiredTags = [];
  
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft match created successfully!')),
          );
          Navigator.of(context).pop();
        } else if (state is DraftMatchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Create Draft Match',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sport Type',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedSport,
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
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter location description',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            prefixIcon: const Icon(Icons.location_on),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a location';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Time',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildTimeField(
                'Start Time',
                _selectedStartTime,
                (dateTime) {
                  setState(() {
                    _selectedStartTime = dateTime;
                    // Ensure end time is after start time
                    if (_selectedEndTime.isBefore(_selectedStartTime)) {
                      _selectedEndTime = _selectedStartTime.add(const Duration(hours: 2));
                    }
                  });
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Expanded(
              child: _buildTimeField(
                'End Time',
                _selectedEndTime,
                (dateTime) {
                  setState(() {
                    _selectedEndTime = dateTime;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeField(String label, DateTime selectedTime, Function(DateTime) onChanged) {
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
              border: Border.all(color: AppTheme.borderColor),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Row(
              children: [
                Icon(Icons.schedule, color: AppTheme.textSecondary),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '${selectedTime.day}/${selectedTime.month}/${selectedTime.year} ${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}',
                    style: AppTheme.bodyMedium,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Players Needed',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        TextFormField(
          controller: _slotsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Enter number of players',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            prefixIcon: const Icon(Icons.people),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter number of players';
            }
            final slots = int.tryParse(value);
            if (slots == null || slots <= 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSkillLevelSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Level',
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.spacingM),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
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
              },
            ),
          ),
        ),
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
    final isLoading = state is DraftMatchLoading;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _createDraftMatch,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryAccent,
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingM),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Create Draft Match',
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

  void _createDraftMatch() {
    if (_formKey.currentState!.validate()) {
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