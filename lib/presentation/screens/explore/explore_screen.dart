import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/location_card_response.dart';
import '../../../data/models/sport_model.dart';
import '../../bloc/explore/explore_bloc.dart';
import '../../bloc/location/location_bloc.dart' hide LocationPermissionDenied;
import 'search_screen.dart';
import 'map_explore_screen.dart';
import 'venue_details_screen.dart';
import 'package:player_connect/core/di/injection.dart';

class ExploreScreen extends StatefulWidget {
  final bool showDraftMatchBanner;
  final String? draftMatchMessage;
  
  const ExploreScreen({
    super.key,
    this.showDraftMatchBanner = false,
    this.draftMatchMessage,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _hasInitialized = false;
  bool _hasTriggeredNearbySearch = false;

  @override
  void initState() {
    super.initState();
    if (!_hasInitialized) {
      context.read<ExploreBloc>().add(const LoadInitialData());
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.scaffoldBackground,
        elevation: 0,
        title: Text(
          'Explore',
          style: AppTheme.headingLarge,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider.value(
                    value: context.read<ExploreBloc>(),
                    child: const SearchScreen(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<ExploreBloc, ExploreState>(
        listener: (context, state) {
          // Auto-trigger SearchNearbyFields when ExploreLoaded is emitted with userLocation
          // but NOT when it's a geocoding update to prevent infinite loop
          if (state is ExploreLoaded && 
              state.userLocation != null && 
              !_hasTriggeredNearbySearch &&
              !state.isGeocodingUpdate) {
            _hasTriggeredNearbySearch = true;
            context.read<ExploreBloc>().add(const SearchNearbyFields());
          }
        },
        child: Column(
          children: [
            // Draft Match Success Banner
            if (widget.showDraftMatchBanner)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade100, Colors.blue.shade100],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.green.shade200),
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green.shade500,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chốt Kèo Nháp',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.draftMatchMessage ?? 
                            'Hãy chọn một sân cụ thể để chốt kèo cho trận đấu. Tất cả những người đã quan tâm sẽ nhận được thông báo.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Main Content
            Expanded(
              child: BlocBuilder<ExploreBloc, ExploreState>(
                builder: (context, state) {
                if (state is ExploreLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
          
          if (state is ExploreError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading data',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reset the trigger flag when retrying
                      _hasTriggeredNearbySearch = false;
                      context.read<ExploreBloc>().add(const LoadInitialData());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          
          if (state is LocationPermissionDenied) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Permission Required',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExploreBloc>().add(const RequestLocationPermission());
                    },
                    child: const Text('Grant Permission'),
                  ),
                ],
              ),
            );
          }
          
          if (state is ExploreLoaded) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Location Display
                  if (state.userLocation != null && state.currentAddress != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.my_location,
                            color: AppTheme.primaryAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Vị trí hiện tại: ${state.currentAddress}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Reset the trigger flag to allow re-triggering
                              _hasTriggeredNearbySearch = false;
                              context.read<ExploreBloc>().add(const SearchNearbyFields());
                            },
                            child: Text(
                              'Làm mới',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.orange.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_off,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Bật vị trí để tìm sân gần bạn',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              context.read<ExploreBloc>().add(const RequestLocationPermission());
                            },
                            child: Text(
                              'Bật vị trí',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Search Bar
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<ExploreBloc>(),
                            child: const SearchScreen(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: AppTheme.cardDecoration,
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tìm kiếm sân, môn thể thao...',
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Categories
                  Text(
                    'Categories',
                    style: AppTheme.headingSmall,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.sports.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildCategoryChip(
                            context,
                            'All',
                            state.selectedSport == null,
                            state,
                          );
                        }
                        final sport = state.sports[index - 1];
                        return _buildCategoryChip(
                          context,
                          sport.name,
                          state.selectedSport == sport.sportCode,
                          state,
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // View Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        state.cardLocations.isNotEmpty ? 'Sân gần bạn (${state.cardLocations.length})' : 'Nearby Locations',
                        style: AppTheme.headingSmall,
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.map,
                              color: AppTheme.primaryAccent,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const MapExploreScreen(),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.filter_list,
                              color: AppTheme.primaryAccent,
                            ),
                            onPressed: () {
                              _showFilterDialog(context);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Locations List
                  Expanded(
                    child: state.cardLocations.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.location_off,
                                  size: 64,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Không tìm thấy sân nào',
                                  style: AppTheme.headingSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Thử điều chỉnh bộ lọc hoặc khu vực tìm kiếm',
                                  style: AppTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                                if (state.userLocation != null)
                                  Column(
                                    children: [
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                        onPressed: () {
                          // Reset the trigger flag to allow search
                          _hasTriggeredNearbySearch = false;
                          context.read<ExploreBloc>().add(const SearchNearbyFields());
                        },
                                        child: const Text('Tìm sân gần đây'),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.cardLocations.length,
                            itemBuilder: (context, index) {
                              return _buildLocationCardFromData(
                                state.cardLocations[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(BuildContext context, String label, bool isSelected, ExploreLoaded state) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool value) {
          // Handle category selection
          if (label == 'All') {
            context.read<ExploreBloc>().add(
              const ApplyFilters(selectedSport: null),
            );
          } else {
            // Find the sport code for this label
            final sport = state.sports.firstWhere(
              (s) => s.name == label,
              orElse: () => SportModel(
                id: 0,
                sportCode: '',
                name: '',
                isActive: false,
              ),
            );
            if (sport.sportCode.isNotEmpty) {
              context.read<ExploreBloc>().add(
                ApplyFilters(selectedSport: sport.sportCode),
              );
            }
          }
        },
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isSelected ? AppTheme.primaryAccent : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildLocationCardFromData(LocationCardResponse location) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<LocationBloc>(), // Create a new instance of LocationBloc
              child: VenueDetailsScreen(slug: location.slug),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: AppTheme.cardDecoration,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: AppTheme.primaryAccent,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.locationName,
                      style: AppTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.address,
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.averageRating?.toString() ?? 'N/A',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Filter Options',
            style: AppTheme.headingSmall,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distance Range',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Within 5 km',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Price Range',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'All prices',
                style: AppTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Rating',
                style: AppTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '4.0+ stars',
                style: AppTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Apply filters here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.inter(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
