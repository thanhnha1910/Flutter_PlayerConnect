import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../explore/search_screen.dart';
import '../explore/map_explore_screen.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/location/location_bloc.dart' as location;
import '../../../presentation/widgets/location_header.dart';
import '../../bloc/explore/explore_bloc.dart' as explore;
import '../../../core/di/injection.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key}) {
    print('=== HomeScreen: Constructor called ===');
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger loading of map data and user location after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=== HomeScreen: Triggering HomeBloc LoadMapData ===');
      context.read<HomeBloc>().add(const LoadMapData());
      // Also trigger LocationBloc to get user's current address
      print('=== HomeScreen: Triggering LocationBloc CheckAndRequestPermission ===');
      context.read<location.LocationBloc>().add(const location.CheckAndRequestPermission());
    });
  }

  // Placeholder data for upcoming match
  final Map<String, dynamic> upcomingMatch = {
    'venueName': 'City Sports Center',
    'address': '123 Main Street, Downtown',
    'dateTime': DateTime.now().add(const Duration(days: 2)),
    'playerCount': 8,
    'maxPlayers': 10,
    'sportType': 'Football',
  };

  // Placeholder data for AI recommendations
  final List<Map<String, dynamic>> aiRecommendations = [
    {
      'id': 1,
      'sportType': 'Basketball',
      'venueName': 'Metro Basketball Court',
      'time': '6:00 PM',
      'playersNeeded': 2,
      'skillLevel': 'Intermediate',
      'distance': '1.2 km',
    },
    {
      'id': 2,
      'sportType': 'Tennis',
      'venueName': 'Riverside Tennis Club',
      'time': '8:00 AM',
      'playersNeeded': 1,
      'skillLevel': 'Beginner',
      'distance': '2.5 km',
    },
    {
      'id': 3,
      'sportType': 'Football',
      'venueName': 'Green Field Stadium',
      'time': '7:30 PM',
      'playersNeeded': 3,
      'skillLevel': 'Advanced',
      'distance': '3.1 km',
    },
    {
      'id': 4,
      'sportType': 'Badminton',
      'venueName': 'Elite Badminton Center',
      'time': '5:00 PM',
      'playersNeeded': 1,
      'skillLevel': 'Intermediate',
      'distance': '0.8 km',
    },
  ];

  // Placeholder data for community feed
  final List<Map<String, dynamic>> communityFeed = [
    {
      'id': 1,
      'type': 'match_joined',
      'userName': 'John Doe',
      'action': 'just joined a match at',
      'venue': 'City Sports Center',
      'time': '2 hours ago',
      'avatar': 'JD',
    },
    {
      'id': 2,
      'type': 'milestone',
      'userName': 'Jane Smith',
      'action': 'achieved a new milestone:',
      'milestone': '10 Matches Played!',
      'time': '4 hours ago',
      'avatar': 'JS',
    },
    {
      'id': 3,
      'type': 'match_created',
      'userName': 'Mike Johnson',
      'action': 'created a new match at',
      'venue': 'Downtown Basketball Court',
      'time': '6 hours ago',
      'avatar': 'MJ',
    },
    {
      'id': 4,
      'type': 'team_formed',
      'userName': 'Sarah Wilson',
      'action': 'formed a new team:',
      'teamName': 'Thunder Bolts',
      'time': '1 day ago',
      'avatar': 'SW',
    },
    {
      'id': 5,
      'type': 'achievement',
      'userName': 'Alex Chen',
      'action': 'won their first tournament at',
      'venue': 'Elite Tennis Club',
      'time': '2 days ago',
      'avatar': 'AC',
    },
  ];

  void _showLocationPermissionDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quyền truy cập vị trí'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<HomeBloc>().add(const RequestLocationPermission());
              },
              child: const Text('Cấp quyền'),
            ),
          ],
        );
      },
    );
  }

  void _showLocationServiceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dịch vụ vị trí'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry loading map data
                context.read<HomeBloc>().add(const LoadMapData());
              },
              child: const Text('Thử lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is LocationPermissionRequired) {
          _showLocationPermissionDialog(context, state.message);
        } else if (state is LocationServiceDisabled) {
          _showLocationServiceDialog(context, state.message);
        } else if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppTheme.scaffoldBackground,
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(),
                _buildServiceGrid(),
                _buildPromotionalBanner(),
                _buildPromotionalCarousel(),
                _buildForYouSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the floating and pinned SliverAppBar with search bar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: true,
      expandedHeight: 140.0,
      backgroundColor: AppTheme.primaryAccent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.primaryGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Location display
                  LocationHeader(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<explore.ExploreBloc>()..add(const explore.LoadInitialData()),
                            child: const SearchScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppTheme.spacingM),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => getIt<explore.ExploreBloc>()
                                    ..add(const explore.LoadInitialData()),
                                  child: const SearchScreen(),
                                ),
                              ),
                            );
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(AppTheme.radiusL),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: AppTheme.spacingM),
                                  child: Icon(
                                    Icons.search,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: AppTheme.spacingS),
                                Expanded(
                                  child: Text(
                                    'Search fields, matches...',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingM),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {
                          // Handle notification tap
                        },
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        child: Text(
                          'AC',
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the service grid with Super App features
  Widget _buildServiceGrid() {
    final services = [
      {'icon': Icons.sports_soccer, 'label': 'Find Field', 'color': AppTheme.primaryAccent},
      {'icon': Icons.group_add, 'label': 'Find Match', 'color': AppTheme.secondaryAccent},
      {'icon': Icons.groups, 'label': 'My Teams', 'color': AppTheme.accentColor},
      {'icon': Icons.account_balance_wallet, 'label': 'Wallet', 'color': AppTheme.primaryAccent},
      {'icon': Icons.emoji_events, 'label': 'Tournaments', 'color': AppTheme.secondaryAccent},
      {'icon': Icons.local_offer, 'label': 'Offers', 'color': AppTheme.accentColor},
      {'icon': Icons.fitness_center, 'label': 'Training', 'color': AppTheme.primaryAccent},
      {'icon': Icons.more_horiz, 'label': 'More', 'color': AppTheme.textSecondary},
    ];

    return SliverPadding(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: AppTheme.spacingM,
          mainAxisSpacing: AppTheme.spacingM,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final service = services[index];
            return GestureDetector(
              onTap: () {
                final service = services[index];
                if (service['label'] == 'Find Field') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => getIt<explore.ExploreBloc>()..add(const explore.LoadInitialData()),
                        child: const MapExploreScreen(),
                      ),
                    ),
                  );
                }
                // Handle other service taps
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  boxShadow: AppTheme.cardShadow,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      service['icon'] as IconData,
                      size: 28,
                      color: service['color'] as Color,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      service['label'] as String,
                      style: AppTheme.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: services.length,
        ),
      ),
    );
  }

  /// Builds the promotional banner
  Widget _buildPromotionalBanner() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          // Handle promotional banner tap
        },
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingL,
            vertical: AppTheme.spacingM,
          ),
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            boxShadow: AppTheme.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            child: Image.asset(
              'assets/banner/bannerPlayerConnect.png',
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryAccent, AppTheme.secondaryAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                  ),
                  child: const Center(
                    child: Text(
                      'Special Promotion',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the promotional carousel
  Widget _buildPromotionalCarousel() {
    final promotions = [
      {
        'title': 'Weekend Tournament',
        'subtitle': 'Join the biggest football event',
        'image': 'assets/images/promo1.jpg',
        'color': AppTheme.primaryAccent,
      },
      {
        'title': 'New Courts Available',
        'subtitle': 'Book premium tennis courts',
        'image': 'assets/images/promo2.jpg',
        'color': AppTheme.secondaryAccent,
      },
      {
        'title': 'Fitness Challenge',
        'subtitle': 'Complete 30 days challenge',
        'image': 'assets/images/promo3.jpg',
        'color': AppTheme.accentColor,
      },
    ];

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingL,
              vertical: AppTheme.spacingM,
            ),
            child: Text(
              'Featured',
              style: AppTheme.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
              itemCount: promotions.length,
              itemBuilder: (context, index) {
                final promo = promotions[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.only(right: AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: promo['color'] as Color,
                    borderRadius: BorderRadius.circular(AppTheme.radiusL),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          promo['title'] as String,
                          style: AppTheme.headlineSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Text(
                          promo['subtitle'] as String,
                          style: AppTheme.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingM),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingM,
                            vertical: AppTheme.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppTheme.radiusM),
                          ),
                          child: Text(
                            'Learn More',
                            style: AppTheme.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "For You" content section
  Widget _buildForYouSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'For You',
                  style: AppTheme.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Handle see all
                  },
                  child: Text(
                    'See All',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...aiRecommendations.take(3).map((recommendation) => _buildRecommendationCard(recommendation)),
          ...communityFeed.take(2).map((feedItem) => _buildFeedItem(feedItem)),
        ],
      ),
    );
  }

  /// Builds a recommendation card
  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
            child: Icon(
              _getSportIconData(recommendation['sportType']),
              color: AppTheme.primaryAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recommendation['venueName'],
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  '${recommendation['time']} • ${recommendation['distance']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(
                  'Need ${recommendation['playersNeeded']} players • ${recommendation['skillLevel']}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.primaryAccent,
                  ),
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
    );
  }

  /// Builds the upcoming match section
  Widget _buildUpcomingMatchSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Upcoming Match', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            _buildUpcomingMatchCard(),
          ],
        ),
      ),
    );
  }

  /// Builds the upcoming match card
  Widget _buildUpcomingMatchCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.secondaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryAccent.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: AppTheme.iconSizeLarge + 4,
                ),
                const SizedBox(width: AppTheme.spacingM),
                Expanded(
                  child: Text(
                    upcomingMatch['sportType'],
                    style: AppTheme.headingSmall.copyWith(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingXS + 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                  ),
                  child: Text(
                    '${upcomingMatch['playerCount']}/${upcomingMatch['maxPlayers']} Players',
                    style: AppTheme.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white70,
                  size: AppTheme.iconSizeMedium - 2,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    upcomingMatch['venueName'],
                    style: AppTheme.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingS),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white70,
                  size: AppTheme.iconSizeMedium - 2,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  _formatDateTime(upcomingMatch['dateTime']),
                  style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle view details
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.secondaryAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                ),
                child: Text('View Details', style: AppTheme.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Discovery Hub section
  Widget _buildDiscoveryHubSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discovery Hub', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
            _buildDiscoveryHubCard(),
            const SizedBox(height: AppTheme.spacingXXL),
          ],
        ),
      ),
    );
  }

  /// Builds the main Discovery Hub card
  Widget _buildDiscoveryHubCard() {
    return Container(
      decoration: AppTheme.elevatedCardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapPreview(),
            const SizedBox(height: AppTheme.spacingL),
            _buildSearchBar(),
            const SizedBox(height: AppTheme.spacingL),
            _buildSmartActionChips(),
          ],
        ),
      ),
    );
  }

  /// Builds the map preview section
  Widget _buildMapPreview() {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryAccent.withValues(alpha: 0.1),
            AppTheme.secondaryAccent.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: AppTheme.borderColor, width: 1),
      ),
      child: Stack(
        children: [
          // Map pattern background
          Positioned.fill(child: CustomPaint(painter: _MapPatternPainter())),
          // Overlay content
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.explore,
                      size: AppTheme.iconSizeXLarge,
                      color: AppTheme.primaryAccent,
                    ),
                    const SizedBox(height: AppTheme.spacingS),
                    Text(
                      'Explore nearby fields',
                      style: AppTheme.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryAccent,
                      ),
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

  /// Builds the search bar
  Widget _buildSearchBar() {
    return TextField(
      decoration: AppTheme.searchInputDecoration,
      onTap: () {
        // Handle search tap - navigate to search screen
      },
      readOnly: true, // Make it read-only to handle navigation
    );
  }

  /// Builds the smart action chips
  Widget _buildSmartActionChips() {
    final chips = [
      {'label': 'Sân gần tôi', 'icon': Icons.location_on},
      {'label': 'Kèo 5v5', 'icon': Icons.groups},
      {'label': 'Sân có mái che', 'icon': Icons.roofing},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingS,
          children: chips.map((chip) {
            return ActionChip(
              avatar: Icon(
                chip['icon'] as IconData,
                size: AppTheme.iconSizeSmall,
                color: AppTheme.primaryAccent,
              ),
              label: Text(
                chip['label'] as String,
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primaryAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.primaryAccent.withValues(alpha: 0.1),
              side: BorderSide(
                color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                width: 1,
              ),
              onPressed: () {
                // Handle chip tap
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the AI recommendations section
  Widget _buildAIRecommendationsSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Colors.amber.shade600,
                  size: AppTheme.iconSizeMedium,
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text('AI Recommendations', style: AppTheme.headingMedium),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
              ),
              itemCount: aiRecommendations.length,
              itemBuilder: (context, index) {
                return _buildRecommendationCard(aiRecommendations[index]);
              },
            ),
          ),
          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }



  /// Builds the community feed section
  Widget _buildCommunityFeedSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Community Feed', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingM),
          ],
        ),
      ),
    );
  }

  /// Builds the community feed list
  Widget _buildCommunityFeedList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index >= communityFeed.length) return null;
        return _buildFeedItem(communityFeed[index]);
      }, childCount: communityFeed.length),
    );
  }

  /// Builds a feed item
  Widget _buildFeedItem(Map<String, dynamic> feedItem) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingL,
        right: AppTheme.spacingL,
        bottom: AppTheme.spacingM,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _getAvatarColor(feedItem['avatar']),
            child: Text(
              feedItem['avatar'],
              style: AppTheme.caption.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: feedItem['userName'],
                        style: AppTheme.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ${feedItem['action']} ',
                        style: AppTheme.bodyMedium,
                      ),
                      if (feedItem['venue'] != null)
                        TextSpan(
                          text: feedItem['venue'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primaryAccent,
                          ),
                        ),
                      if (feedItem['milestone'] != null)
                        TextSpan(
                          text: feedItem['milestone'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.amber.shade600,
                          ),
                        ),
                      if (feedItem['teamName'] != null)
                        TextSpan(
                          text: feedItem['teamName'],
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryAccent,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXS),
                Text(feedItem['time'], style: AppTheme.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to format date time
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'Soon';
    }
  }

  /// Helper method to get sport icon data
  IconData _getSportIconData(String sportType) {
    switch (sportType.toLowerCase()) {
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_handball;
      default:
        return Icons.sports;
    }
  }

  /// Helper method to get avatar color
  Color _getAvatarColor(String avatar) {
    final colors = [
      Colors.blue.shade600,
      Colors.green.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.red.shade600,
    ];

    return colors[avatar.hashCode % colors.length];
  }
}

/// Custom painter for creating a map-like pattern background
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryAccent.withValues(alpha: 0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw grid pattern to simulate map
    const gridSize = 20.0;

    // Vertical lines
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Horizontal lines
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Add some random "road" lines for map effect
    final roadPaint = Paint()
      ..color = AppTheme.primaryAccent.withValues(alpha: 0.2)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Diagonal "roads"
    canvas.drawLine(
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.8, size.height),
      roadPaint,
    );

    canvas.drawLine(
      Offset(0, size.height * 0.3),
      Offset(size.width, size.height * 0.7),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
