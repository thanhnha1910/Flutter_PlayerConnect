import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_theme.dart';

class SmartSearchBar extends StatefulWidget {
  final Function(String)? onSearchChanged;
  final Function(Position)? onLocationDetected;
  
  const SmartSearchBar({
    super.key,
    this.onSearchChanged,
    this.onLocationDetected,
  });

  @override
  State<SmartSearchBar> createState() => _SmartSearchBarState();
}

class _SmartSearchBarState extends State<SmartSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoadingLocation = false;
  String? _currentLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search TextField
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sân thể thao...',
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppTheme.primaryAccent,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          
          // Location Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: InkWell(
              onTap: _getCurrentLocation,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    if (_isLoadingLocation)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.successColor,
                          ),
                        ),
                      )
                    else
                      const Icon(
                        Icons.my_location,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _currentLocation ?? 'Sử dụng vị trí hiện tại của tôi',
                        style: TextStyle(
                          color: _currentLocation != null
                              ? AppTheme.successColor
                              : Colors.grey[600],
                          fontWeight: _currentLocation != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (_currentLocation != null)
                      Icon(
                        Icons.check_circle,
                        color: AppTheme.successColor,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Quyền truy cập vị trí bị từ chối');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Quyền truy cập vị trí bị từ chối vĩnh viễn');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = 'Vị trí hiện tại (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
      });

      widget.onLocationDetected?.call(position);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}