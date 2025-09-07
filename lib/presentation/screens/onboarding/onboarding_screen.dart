import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../widgets/onboarding/multi_select_sport_widget.dart';
import '../../widgets/onboarding/sport_profile_card.dart';
import '../../../data/models/sport_model.dart';
import '../../../data/models/sport_profile_model.dart';
import '../../../data/models/tag_model.dart';
import '../../../data/models/onboarding_request_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  List<SportModel> _selectedSports = [];
  Map<int, SportProfileModel> _sportProfiles = {};
  List<SportModel> _availableSports = [];
  List<TagModel> _availableTags = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Load sports first
    context.read<OnboardingBloc>().add(const LoadSports());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Thiết lập hồ sơ thể thao'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        body: BlocConsumer<OnboardingBloc, OnboardingState>(
          listener: (context, state) {
            if (state is OnboardingCompleted) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thiết lập hồ sơ thành công!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                context.read<AuthBloc>().add(AuthCheckRequested());
                Navigator.of(context).pushReplacementNamed('/home');
              });
            } else if (state is OnboardingError) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Thử lại',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<OnboardingBloc>().add(const LoadSports());
                    },
                  ),
                ),
              );
            } else if (state is SportsLoaded) {
              setState(() {
                _availableSports = state.sports;
                _isLoading = false;
              });
            } else if (state is OnboardingLoading) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          builder: (context, state) {
            if (state is OnboardingLoading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách môn thể thao...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }
            
            return Stack(
              children: [
                _buildOnboardingForm(context, state),
                if (_isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: Colors.green,
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Đang xử lý...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      );
    
  }

  Widget _buildOnboardingForm(BuildContext context, OnboardingState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 32),
          
          // Sports Selection Section
          _buildSportsSelectionSection(state),
          const SizedBox(height: 24),
          
          // Sport Profiles Section
          if (_selectedSports.isNotEmpty) ...[
            _buildSportProfilesSection(),
            const SizedBox(height: 32),
          ],
          
          // Validation Message
          _buildValidationMessage(),
          
          // Action Buttons
          _buildActionButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.green, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thiết lập hồ sơ thể thao',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Chọn môn thể thao và mô tả kỹ năng của bạn',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSportsSelectionSection(OnboardingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.directions_run, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Chọn môn thể thao',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (state is SportsLoaded) ...[
          MultiSelectSportWidget(
            availableSports: _availableSports,
            selectedSports: _selectedSports,
            onSportsChanged: (sports) {
              setState(() {
                _selectedSports = sports;
                // Initialize profiles for new sports
                for (var sport in sports) {
                  if (!_sportProfiles.containsKey(sport.id)) {
                    _sportProfiles[sport.id] = SportProfileModel(
                       sportId: sport.id,
                       sportName: sport.name,
                       skill: 3,
                       tags: [],
                     );
                  }
                }
                // Remove profiles for deselected sports
                _sportProfiles.removeWhere((key, value) => 
                  !sports.any((sport) => sport.id == key));
              });
            },
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircularProgressIndicator(strokeWidth: 2),
                SizedBox(width: 12),
                Text('Đang tải danh sách môn thể thao...'),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildSportProfilesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.settings, color: Colors.green, size: 20),
            SizedBox(width: 8),
            Text(
              'Thiết lập hồ sơ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...(_selectedSports.map((sport) {
          final profile = _sportProfiles[sport.id];
          if (profile == null) return const SizedBox.shrink();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SportProfileCard(
              sport: sport,
              profile: profile,
              availableTags: _availableTags,
              onProfileChanged: (updatedProfile) {
                setState(() {
                  _sportProfiles[sport.id] = updatedProfile;
                });
              },
              onRemove: () {
                setState(() {
                  _selectedSports.removeWhere((s) => s.id == sport.id);
                  _sportProfiles.remove(sport.id);
                });
              },
            ),
          );
        }).toList()),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    final bool isFormValid = _validateForm();
    final String? validationMessage = _getValidationMessage();
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isFormValid && !_isLoading ? _handleComplete : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Đang lưu...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                )
              : const Text(
                  'Hoàn thành',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildValidationMessage() {
    final validationMessage = _getValidationMessage();
    if (validationMessage == null) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        border: Border.all(color: Colors.orange[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              validationMessage,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  bool _validateForm() {
    if (_selectedSports.isEmpty) return false;
    
    return _sportProfiles.values.every((profile) => 
      profile.skill >= 1 && profile.skill <= 5 && 
      profile.tags.isNotEmpty &&
      profile.tags.length <= 5
    );
  }
  
  String? _getValidationMessage() {
    if (_selectedSports.isEmpty) {
      return 'Vui lòng chọn ít nhất một môn thể thao';
    }
    
    for (var profile in _sportProfiles.values) {
      if (profile.skill < 1 || profile.skill > 5) {
        return 'Vui lòng đánh giá kỹ năng từ 1-5 sao cho tất cả môn thể thao';
      }
      if (profile.tags.isEmpty) {
        return 'Vui lòng chọn ít nhất một tag cho mỗi môn thể thao';
      }
      if (profile.tags.length > 5) {
        return 'Mỗi môn thể thao chỉ được chọn tối đa 5 tags';
      }
    }
    
    return null;
  }
  
  void _handleComplete() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getValidationMessage() ?? 'Vui lòng hoàn thành tất cả thông tin'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final profiles = _sportProfiles.values.map((profile) => SportProfileRequest(
      sportId: profile.sportId,
      sportName: profile.sportName,
      sportIcon: profile.sportIcon,
      skill: profile.skill,
      tags: profile.tags.map((tag) {
        // Only include tagId for existing tags (id > 0)
        // For new tags created by user, don't include tagId
        if (tag.id > 0) {
          return TagRequest(
            tagId: tag.id,
            tagName: tag.name,
            tagType: tag.tagType,
          );
        } else {
          // New tag - don't include tagId
          return TagRequest(
            tagName: tag.name,
            tagType: tag.tagType,
          );
        }
      }).toList(),
    )).toList();
    final request = OnboardingRequestModel(sportProfiles: profiles);
     context.read<OnboardingBloc>().add(SubmitOnboarding(request: request));
  }
}