import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:player_connect/presentation/screens/explore/venue_details_screen.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../core/theme/app_theme.dart';
import 'explore_screen.dart';
import '../../bloc/explore/explore_bloc.dart';
import '../../bloc/location/location_bloc.dart' as location;
import '../../../data/models/location_card_response.dart';
import '../../../data/models/location_map_model.dart';
import 'search_screen.dart';
import '../../../core/di/injection.dart';

class MapExploreScreen extends StatefulWidget {
  const MapExploreScreen({super.key});

  @override
  State<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends State<MapExploreScreen> {
  GoogleMapController? _mapController;
  final PanelController _panelController = PanelController();
  Set<Marker> _markers = {};
  Timer? _debounce;
  Timer? _cameraIdleTimer;
  
  // Enhanced debouncing configuration
  static const Duration _cameraIdleDebounce = Duration(milliseconds: 800);
  
  // Default location (can be updated when user location is available)
  static const CameraPosition _defaultLocation = CameraPosition(
    target: LatLng(10.8231, 106.6297), // Ho Chi Minh City
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ExploreBloc>(),
      child: MultiBlocListener(
        listeners: [
          BlocListener<location.LocationBloc, location.LocationState>(
            listener: (context, locationState) {
              if (locationState is location.LocationAvailable) {
                // Trigger initial search when location becomes available
                context.read<ExploreBloc>().add(
                  const SearchNearbyFields(customRadius: 5.0), // 5km default radius
                );
              }
            },
          ),
          BlocListener<ExploreBloc, ExploreState>(
            listener: (context, state) {
              if (state is ExploreLoaded) {
                _updateMapMarkers(state.mapLocations);
                if (state.userLocation != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          state.userLocation!.latitude,
                          state.userLocation!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
        child: BlocConsumer<ExploreBloc, ExploreState>(
          listener: (context, state) {
            // Additional listeners if needed
          },
          builder: (context, state) {
          if (state is ExploreLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (state is ExploreError) {
            return _buildErrorView(state.message);
          }
          
          if (state is LocationPermissionDenied) {
            return _buildPermissionDeniedView(state.message);
          }
          
          if (state is LocationPermissionRequired) {
            return _buildPermissionDeniedView(state.message);
          }
          
          if (state is ExploreLoaded) {
            return _buildMapWithPanel(state);
          }
          
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      )
    );
    
  }

  Widget _buildMapWithPanel(ExploreLoaded state) {
    return SlidingUpPanel(
      controller: _panelController,
      minHeight: 120,
      maxHeight: MediaQuery.of(context).size.height * 0.7,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      panel: _buildPanel(state),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _defaultLocation,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onCameraMove: (CameraPosition position) {
              // Handle camera movement for loading nearby locations
            },
            onCameraIdle: _onCameraIdle,
          ),
          
          // Top overlay with search and controls
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: _buildTopOverlay(),
          ),
          
          // My Location Button
          Positioned(
            bottom: 200,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                if (state.userLocation != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(
                          state.userLocation!.latitude,
                          state.userLocation!.longitude,
                        ),
                        zoom: 15.0,
                      ),
                    ),
                  );
                } else {
                  // Request location permission if not available
                  context.read<ExploreBloc>().add(const RequestLocationPermission());
                }
              },
              child: Icon(
                state.userLocation != null ? Icons.my_location : Icons.location_searching,
                color: AppTheme.primaryAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Column(
      children: [
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Search locations, sports...',
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Filter chips
        BlocBuilder<ExploreBloc, ExploreState>(
          builder: (context, state) {
            if (state is ExploreLoaded && state.sports.isNotEmpty) {
              return SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.sports.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildFilterChip(
                        'All',
                        state.selectedSport == null,
                        () {
                          context.read<ExploreBloc>().add(
                            const ApplyFilters(selectedSport: null),
                          );
                        },
                      );
                    }
                    final sport = state.sports[index - 1];
                    return _buildFilterChip(
                      sport.name,
                      state.selectedSport == sport.sportCode,
                      () {
                        context.read<ExploreBloc>().add(
                          ApplyFilters(selectedSport: sport.sportCode),
                        );
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryAccent : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanel(ExploreLoaded state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Panel handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Panel header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nearby Locations (${state.cardLocations.length})',
                  style: AppTheme.headingSmall,
                ),
                IconButton(
                  icon: Icon(
                    Icons.list,
                    color: AppTheme.primaryAccent,
                  ),
                  onPressed: () {
                    // Navigate to list view
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const ExploreScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Locations list
          Expanded(
            child: state.cardLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_off,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No locations found in this area',
                          style: AppTheme.bodyLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try moving the map or adjusting filters',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.cardLocations.length,
                    itemBuilder: (context, index) {
                      return _buildLocationCard(state.cardLocations[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(LocationCardResponse location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardDecoration,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VenueDetailsScreen(slug: location.slug),
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
                  color: AppTheme.primaryAccent.withOpacity(0.1),
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
                            'From ',
                            style: AppTheme.bodySmall,
                          ),
                          Text(
                            '\${location.startingPrice!.toStringAsFixed(0)}/hr',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        ],
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

  Widget _buildErrorView(String message) {
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
            message,
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

  Widget _buildPermissionDeniedView(String message) {
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
            message,
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
                Icons.location_on,
                color: AppTheme.primaryAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Location Access',
                style: AppTheme.headingSmall.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'To show nearby sports fields and provide the best experience, we need access to your location.',
                style: AppTheme.bodyMedium.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
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
                        'Your location data is only used to find nearby venues and is never shared.',
                        style: AppTheme.bodySmall.copyWith(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
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
                // Navigate to SearchScreen for manual entry
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<ExploreBloc>(),
                      child: const SearchScreen(),
                    ),
                  ),
                );
              },
              child: Text(
                'Enter Location Manually',
                style: GoogleFonts.inter(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<ExploreBloc>().add(const RequestLocationPermission());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Grant Permission',
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

  void _updateMapMarkers(List<LocationMapModel> locations) {
    final markers = <Marker>{};
    
    for (int i = 0; i < locations.length; i++) {
      final location = locations[i];
      markers.add(
        Marker(
          markerId: MarkerId(location.locationId.toString()),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(
            title: location.name,
            snippet: location.address,
          ),
          onTap: () {
            // TODO: Show location details or focus on location in panel
          },
        ),
      );
    }
    
    setState(() {
      _markers = markers;
    });
  }

  double _calculateRadius(LatLngBounds bounds) {
    // Calculate approximate radius in kilometers based on visible region
    const double earthRadius = 6371; // Earth's radius in km
    
    final double lat1 = bounds.southwest.latitude;
    final double lat2 = bounds.northeast.latitude;
    final double lon1 = bounds.southwest.longitude;
    final double lon2 = bounds.northeast.longitude;
    
    final double dLat = (lat2 - lat1) * (3.14159 / 180);
    final double dLon = (lon2 - lon1) * (3.14159 / 180);
    
    final double a = (dLat / 2) * (dLat / 2) + (dLon / 2) * (dLon / 2);
    final double c = 2 * sqrt(a);
    final double distance = earthRadius * c;
    
    return distance / 2; // Return half the diagonal as radius
  }

  void _onCameraIdle() {
    if (_mapController == null) return;
    
    // Cancel previous timer if it exists
    _cameraIdleTimer?.cancel();
    
    // Set a new timer with enhanced debounce delay
    _cameraIdleTimer = Timer(_cameraIdleDebounce, () async {
      try {
        final LatLngBounds bounds = await _mapController!.getVisibleRegion();
        final LatLng center = LatLng(
          (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
          (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
        );
        
        final double radius = _calculateRadius(bounds);
        
        print('[MAP] Camera idle - triggering search at lat: ${center.latitude}, lng: ${center.longitude}, radius: $radius');
        
        if (mounted) {
          context.read<ExploreBloc>().add(
            SearchLocationsInArea(
              latitude: center.latitude,
              longitude: center.longitude,
              radius: radius,
            ),
          );
        }
      } catch (e) {
        print('[MAP] Error in camera idle: $e');
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _cameraIdleTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }
}