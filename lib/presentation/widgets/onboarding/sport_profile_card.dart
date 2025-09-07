import 'package:flutter/material.dart';
import '../../../data/models/sport_model.dart';
import '../../../data/models/sport_profile_model.dart';
import '../../../data/models/tag_model.dart';
import 'tag_selector_widget.dart';

class SportProfileCard extends StatefulWidget {
  final SportModel sport;
  final SportProfileModel? profile;
  final List<TagModel> availableTags;
  final Function(SportProfileModel) onProfileChanged;
  final VoidCallback? onRemove;
  final bool isLoading;

  const SportProfileCard({
    Key? key,
    required this.sport,
    this.profile,
    required this.availableTags,
    required this.onProfileChanged,
    this.onRemove,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<SportProfileCard> createState() => _SportProfileCardState();
}

class _SportProfileCardState extends State<SportProfileCard> {
  late int _skillLevel;
  late List<TagModel> _selectedTags;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _skillLevel = widget.profile?.skill ?? 1;
    _selectedTags = widget.profile?.tags ?? [];
  }

  @override
  void didUpdateWidget(SportProfileCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profile != oldWidget.profile) {
      _skillLevel = widget.profile?.skill ?? 1;
      _selectedTags = widget.profile?.tags ?? [];
    }
  }

  void _updateProfile() {
    final profile = SportProfileModel(
      id: widget.profile?.id,
      sportId: widget.sport.id,
      sportName: widget.sport.name,
      sportIcon: widget.sport.icon,
      skill: _skillLevel,
      tags: _selectedTags,
    );
    widget.onProfileChanged(profile);
  }

  void _onSkillChanged(double value) {
    setState(() {
      _skillLevel = value.round();
    });
    _updateProfile();
  }

  void _onTagsChanged(List<TagModel> tags) {
    setState(() {
      _selectedTags = tags;
    });
    _updateProfile();
  }

  String _getSkillLabel(int skill) {
    switch (skill) {
      case 1:
        return 'Mới bắt đầu';
      case 2:
        return 'Cơ bản';
      case 3:
        return 'Trung bình';
      case 4:
        return 'Khá';
      case 5:
        return 'Chuyên nghiệp';
      default:
        return 'Không xác định';
    }
  }

  Color _getSkillColor(int skill) {
    switch (skill) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.yellow[700]!;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header
          ListTile(
            leading: widget.sport.icon != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(widget.sport.icon!),
                    radius: 20,
                  )
                : CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: const Icon(Icons.sports, color: Colors.white),
                    radius: 20,
                  ),
            title: Text(
              widget.sport.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text('Mã: ${widget.sport.sportCode}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
                    tooltip: 'Xóa môn thể thao',
                  ),
                IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ],
            ),
          ),
          
          // Expandable content
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skill level section
                  Text(
                    'Trình độ kỹ năng',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Skill slider
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _skillLevel.toDouble(),
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: _getSkillLabel(_skillLevel),
                          onChanged: _onSkillChanged,
                          activeColor: _getSkillColor(_skillLevel),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getSkillColor(_skillLevel).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getSkillColor(_skillLevel),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _getSkillLabel(_skillLevel),
                          style: TextStyle(
                            color: _getSkillColor(_skillLevel),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Star rating display
                  Row(
                    children: [
                      const Text('Đánh giá: '),
                      ...List.generate(5, (index) {
                        return Icon(
                          index < _skillLevel ? Icons.star : Icons.star_border,
                          color: _getSkillColor(_skillLevel),
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 8),
                      Text(
                        '$_skillLevel/5',
                        style: TextStyle(
                          color: _getSkillColor(_skillLevel),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tags section
                  TagSelectorWidget(
                    availableTags: widget.availableTags,
                    selectedTags: _selectedTags,
                    onTagsChanged: _onTagsChanged,
                    isLoading: widget.isLoading,
                    sportId: widget.sport.id.toString(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}