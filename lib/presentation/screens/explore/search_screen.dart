import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/explore/explore_bloc.dart';
import '../../../data/models/location_card_response.dart';
import '../../../data/models/sport_model.dart';
import 'map_explore_screen.dart';
import 'venue_details_screen.dart';
import 'package:player_connect/presentation/bloc/location/location_bloc.dart' hide LocationPermissionDenied;
import 'package:player_connect/core/di/injection.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  
  // Recent searches will be loaded from user preferences
  final List<String> _recentSearches = [];
  
  // Popular searches will be loaded from backend
  final List<String> _popularSearches = [];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field and load all locations when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      context.read<ExploreBloc>().add(const LoadAllLocations());
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _showLocationPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.location_off,
                color: AppTheme.primaryAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Cần quyền truy cập vị trí',
                style: AppTheme.headingSmall,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Để tìm sân gần bạn, ứng dụng cần quyền truy cập vị trí của bạn.',
                style: AppTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryAccent,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Vị trí của bạn chỉ được sử dụng để tìm sân thể thao gần nhất',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Bỏ qua',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Search nearby fields with 5km radius
                context.read<ExploreBloc>().add(const SearchNearbyFields(customRadius: 5.0));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Cho phép',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExploreBloc, ExploreState>(
        listener: (context, state) {
          if (state is LocationPermissionDenied) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showLocationPermissionDialog(context, state.message);
            });
          }
        },
        child: Scaffold(
          backgroundColor: AppTheme.scaffoldBackground,
          appBar: AppBar(
            backgroundColor: AppTheme.scaffoldBackground,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
          title: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.borderColor),
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search locations, sports...',
                hintStyle: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ExploreBloc>().add(const LoadAllLocations());
                          setState(() {});
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onChanged: (value) {
                setState(() {});
                
                // Cancel previous timer
                _debounceTimer?.cancel();
                
                if (value.isNotEmpty) {
                  // Start new timer for debounced search
                  _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value && mounted) {
                      context.read<ExploreBloc>().add(SearchByText(searchQuery: value));
                    }
                  });
                } else {
                  // Clear search results when input is empty
                  context.read<ExploreBloc>().add(const LoadAllLocations());
                }
              },
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<ExploreBloc>().add(SearchByText(searchQuery: value));
                }
              },
            ),
          ),
        ),
        body: BlocBuilder<ExploreBloc, ExploreState>(
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
                      'Error loading search results',
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
                        context.read<ExploreBloc>().add(const LoadInitialData());
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            
            if (state is ExploreLoaded) {
              // Show search results if there's a search query
              if (_searchController.text.isNotEmpty) {
                return _buildSearchResults(state.cardLocations);
              }
              
              // Show nearby fields results if mapLocations are available and searchRadius is set
              if (state.mapLocations.isNotEmpty && state.searchRadius != null) {
                return _buildNearbyFieldsResults(state);
              }
              
              // Show contextual suggestions when no search query
              return _buildSearchSuggestions(state.sports);
            }
            
            return _buildSearchSuggestions([]);
          },
        ),
      ),
    );
  }

  Widget _buildSearchResults(List<LocationCardResponse> locations) {
    if (locations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử từ khóa khác hoặc kiểm tra chính tả',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return _buildLocationCard(
              locations[index],
              userLocation: state is ExploreLoaded ? state.userLocation : null,
            );
          },
        );
      },
    );
  }

  Widget _buildSearchSuggestions(List<SportModel> sports) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Location Display
          BlocBuilder<ExploreBloc, ExploreState>(
            builder: (context, state) {
              if (state is ExploreLoaded && state.currentAddress != null) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        color: AppTheme.primaryAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Vị trí hiện tại',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.currentAddress!,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          
          // Search Near You Button
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                bool isSearchingLocation = state is ExploreLoading;
                
                return ElevatedButton.icon(
                  onPressed: isSearchingLocation ? null : () {
                    // Search for nearby fields with 5km radius
                    context.read<ExploreBloc>().add(const SearchNearbyFields(customRadius: 5.0));
                  },
                  icon: isSearchingLocation 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20,
                      ),
                  label: Text(
                    isSearchingLocation 
                      ? 'Đang lấy vị trí...'
                      : 'Tìm sân gần bạn (5km)',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSearchingLocation 
                      ? AppTheme.textSecondary 
                      : AppTheme.primaryAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                );
              },
            ),
          ),
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            Text(
              'Recent Searches',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            ..._recentSearches.map((search) => _buildSuggestionItem(
              icon: Icons.history,
              title: search,
              onTap: () {
                _searchController.text = search;
                context.read<ExploreBloc>().add(SearchByText(searchQuery: search));
              },
            )),
            const SizedBox(height: 24),
          ],
          
          // Sports Categories
          if (sports.isNotEmpty) ...[
            Text(
              'Browse by Sport',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 12),
            ...sports.take(6).map((sport) => _buildSuggestionItem(
              icon: Icons.sports,
              title: sport.name,
              onTap: () {
                _searchController.text = sport.name;
                context.read<ExploreBloc>().add(SearchByText(searchQuery: sport.name));
              },
            )),
            const SizedBox(height: 24),
          ],
          
          // Popular Searches
          Text(
            'Popular Searches',
            style: AppTheme.headingSmall,
          ),
          const SizedBox(height: 12),
          ..._popularSearches.map((search) => _buildSuggestionItem(
            icon: Icons.trending_up,
            title: search,
            onTap: () {
              _searchController.text = search;
              context.read<ExploreBloc>().add(SearchByText(searchQuery: search));
            },
          )),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.north_west,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000; // Convert to km
  }

  Widget _buildNearbyFieldsResults(ExploreLoaded state) {
    if (state.mapLocations.isEmpty) {
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
              'Không tìm thấy sân gần bạn',
              style: AppTheme.headingSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tăng bán kính tìm kiếm hoặc kiểm tra vị trí của bạn',
              style: AppTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header with results count and radius
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppTheme.primaryAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tìm thấy ${state.mapLocations.length} sân trong bán kính ${state.searchRadius?.toStringAsFixed(0)} km',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to map view
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const MapExploreScreen(),
                    ),
                  );
                },
                child: Text(
                  'Xem bản đồ',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        // List of nearby locations
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.mapLocations.length,
            itemBuilder: (context, index) {
              final mapLocation = state.mapLocations[index];
               // Convert MapLocation to LocationCardResponse for display
               final locationCard = LocationCardResponse(
                 locationId: mapLocation.locationId,
                 locationName: mapLocation.name,
                 slug: mapLocation.slug,
                 address: mapLocation.address,
                 averageRating: mapLocation.averageRating,
                 startingPrice: null, // Not available in map model
                 mainImageUrl: mapLocation.thumbnailImageUrl,
                 fieldCount: mapLocation.fieldCount,
                 bookingCount: 0,
                 distance: mapLocation.distance,
               );
              
              return _buildLocationCard(
                locationCard,
                userLocation: state.userLocation,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(LocationCardResponse location, {Position? userLocation}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: InkWell(
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: location.mainImageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          location.mainImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.sports_soccer,
                              color: AppTheme.primaryAccent,
                              size: 30,
                            );
                          },
                        ),
                      )
                    : Icon(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                        Expanded(
                          child: Text(
                            location.address,
                            style: AppTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location.averageRating?.toStringAsFixed(1) ?? 'N/A',
                          style: AppTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        if (location.startingPrice != null) ...[
                          Text(
                            'Từ ',
                            style: AppTheme.bodySmall,
                          ),
                          Text(
                            '${location.startingPrice!.toStringAsFixed(0)}k/giờ',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ],
                      ],
                    ),
                    // Show distance if available
                    if (location.distance != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.directions_walk,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${location.distance!.toStringAsFixed(1)} km',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
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
}