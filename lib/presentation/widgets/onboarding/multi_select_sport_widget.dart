import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/sport_model.dart';
import '../../bloc/onboarding/onboarding_bloc.dart';

class MultiSelectSportWidget extends StatefulWidget {
  final List<SportModel> availableSports;
  final List<SportModel> selectedSports;
  final Function(List<SportModel>) onSportsChanged;
  final bool isLoading;

  const MultiSelectSportWidget({
    Key? key,
    required this.availableSports,
    required this.selectedSports,
    required this.onSportsChanged,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<MultiSelectSportWidget> createState() => _MultiSelectSportWidgetState();
}

class _MultiSelectSportWidgetState extends State<MultiSelectSportWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<SportModel> _filteredSports = [];
  bool _showCreateOption = false;

  @override
  void initState() {
    super.initState();
    _filteredSports = widget.availableSports;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredSports = widget.availableSports;
        _showCreateOption = false;
      } else {
        _filteredSports = widget.availableSports
            .where((sport) => sport.name.toLowerCase().contains(query))
            .toList();
        
        // Show create option if no exact match found
        _showCreateOption = !widget.availableSports
            .any((sport) => sport.name.toLowerCase() == query);
      }
    });
  }

  void _toggleSport(SportModel sport) {
    final List<SportModel> updatedSports = List.from(widget.selectedSports);
    
    if (updatedSports.any((s) => s.id == sport.id)) {
      updatedSports.removeWhere((s) => s.id == sport.id);
    } else {
      updatedSports.add(sport);
    }
    
    widget.onSportsChanged(updatedSports);
  }

  void _createNewSport() {
    final sportName = _searchController.text.trim();
    if (sportName.isNotEmpty) {
      // Create a temporary sport model for new sport
      final newSport = SportModel(
        id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
        name: sportName,
        sportCode: sportName.toLowerCase().replaceAll(' ', '_'),
        isActive: true,
      );
      
      final List<SportModel> updatedSports = List.from(widget.selectedSports);
      updatedSports.add(newSport);
      widget.onSportsChanged(updatedSports);
      
      _searchController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chọn môn thể thao',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm hoặc tạo môn thể thao mới...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        const SizedBox(height: 16),
        
        // Selected sports chips
        if (widget.selectedSports.isNotEmpty) ...[
          Text(
            'Đã chọn (${widget.selectedSports.length})',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedSports.map((sport) {
              return Chip(
                label: Text(sport.name),
                avatar: sport.icon != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(sport.icon!),
                        radius: 12,
                      )
                    : const CircleAvatar(
                        child: Icon(Icons.sports, size: 16),
                        radius: 12,
                      ),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => _toggleSport(sport),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                deleteIconColor: Theme.of(context).primaryColor,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        
        // Available sports list
        if (widget.isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          Text(
            'Có thể chọn',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Create new sport option
          if (_showCreateOption && _searchController.text.trim().isNotEmpty)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                title: Text('Tạo "${_searchController.text.trim()}"'),
                subtitle: const Text('Tạo môn thể thao mới'),
                onTap: _createNewSport,
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          
          // Sports list
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _filteredSports.length,
              itemBuilder: (context, index) {
                final sport = _filteredSports[index];
                final isSelected = widget.selectedSports.any((s) => s.id == sport.id);
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: sport.icon != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(sport.icon!),
                          )
                        : const CircleAvatar(
                            child: Icon(Icons.sports),
                          ),
                    title: Text(
                      sport.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text('Mã: ${sport.sportCode}'),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_circle,
                            color: Theme.of(context).primaryColor,
                          )
                        : const Icon(Icons.add_circle_outline),
                    onTap: () => _toggleSport(sport),
                    selected: isSelected,
                    selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}