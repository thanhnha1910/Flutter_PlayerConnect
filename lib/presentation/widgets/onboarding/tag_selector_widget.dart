import 'package:flutter/material.dart';
import '../../../data/models/tag_model.dart';

class TagSelectorWidget extends StatefulWidget {
  final List<TagModel> availableTags;
  final List<TagModel> selectedTags;
  final Function(List<TagModel>) onTagsChanged;
  final bool isLoading;
  final String sportId;
  final int maxTags;

  const TagSelectorWidget({
    Key? key,
    required this.availableTags,
    required this.selectedTags,
    required this.onTagsChanged,
    this.isLoading = false,
    required this.sportId,
    this.maxTags = 10,
  }) : super(key: key);

  @override
  State<TagSelectorWidget> createState() => _TagSelectorWidgetState();
}

class _TagSelectorWidgetState extends State<TagSelectorWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();
  List<TagModel> _filteredTags = [];
  bool _showCreateForm = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredTags = widget.availableTags;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _newTagController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TagSelectorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.availableTags != oldWidget.availableTags) {
      _filterTags();
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
    _filterTags();
  }

  void _filterTags() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredTags = widget.availableTags;
      } else {
        _filteredTags = widget.availableTags
            .where((tag) => tag.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }
    });
  }

  void _toggleTag(TagModel tag) {
    if (widget.selectedTags.contains(tag)) {
      // Remove tag
      final updatedTags = List<TagModel>.from(widget.selectedTags);
      updatedTags.remove(tag);
      widget.onTagsChanged(updatedTags);
    } else {
      // Add tag if under limit
      if (widget.selectedTags.length < widget.maxTags) {
        final updatedTags = List<TagModel>.from(widget.selectedTags);
        updatedTags.add(tag);
        widget.onTagsChanged(updatedTags);
      } else {
        _showMaxTagsDialog();
      }
    }
  }

  void _showMaxTagsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giới hạn tags'),
        content: Text('Bạn chỉ có thể chọn tối đa ${widget.maxTags} tags cho mỗi môn thể thao.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _createNewTag() {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;

    // Check if tag already exists
    final existingTag = widget.availableTags
        .where((tag) => tag.name.toLowerCase() == tagName.toLowerCase())
        .firstOrNull;
    
    if (existingTag != null) {
      _showTagExistsDialog(existingTag);
      return;
    }

    // Create new tag (in real app, this would call API)
    final newTag = TagModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Negative ID for new tags
      name: tagName,
      tagType: 'custom',
      sportId: int.tryParse(widget.sportId) ?? 0,
    );

    // Add to selected tags
    if (widget.selectedTags.length < widget.maxTags) {
      final updatedTags = List<TagModel>.from(widget.selectedTags);
      updatedTags.add(newTag);
      widget.onTagsChanged(updatedTags);
    }

    // Clear form and hide
    _newTagController.clear();
    setState(() {
      _showCreateForm = false;
    });
  }

  void _showTagExistsDialog(TagModel existingTag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tag đã tồn tại'),
        content: Text('Tag "${existingTag.name}" đã có trong danh sách. Bạn có muốn chọn nó không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _toggleTag(existingTag);
            },
            child: const Text('Chọn'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        Row(
          children: [
            Text(
              'Tags & Sở thích',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.selectedTags.length}/${widget.maxTags}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.selectedTags.length >= widget.maxTags 
                    ? Colors.red 
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm tags...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Selected tags
        if (widget.selectedTags.isNotEmpty) ...[
          Text(
            'Đã chọn:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.selectedTags.map((tag) {
              return Chip(
                label: Text(tag.name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _toggleTag(tag),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                side: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 1,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],

        // Available tags
        if (_filteredTags.isNotEmpty) ...[
          Text(
            'Có thể chọn:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _filteredTags
                .where((tag) => !widget.selectedTags.contains(tag))
                .map((tag) {
              return ActionChip(
                label: Text(tag.name),
                onPressed: () => _toggleTag(tag),
                backgroundColor: Colors.grey[100],
                side: BorderSide(
                  color: Colors.grey[400]!,
                  width: 1,
                ),
              );
            }).toList(),
          ),
        ] else if (_searchQuery.isNotEmpty) ...[
          Text(
            'Không tìm thấy tag nào.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],

        const SizedBox(height: 12),

        // Create new tag section
        if (!_showCreateForm) ...[
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showCreateForm = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Tạo tag mới'),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo tag mới:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newTagController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tên tag...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (_) => _createNewTag(),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _createNewTag,
                      child: const Text('Tạo'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        _newTagController.clear();
                        setState(() {
                          _showCreateForm = false;
                        });
                      },
                      child: const Text('Hủy'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (widget.isLoading)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}