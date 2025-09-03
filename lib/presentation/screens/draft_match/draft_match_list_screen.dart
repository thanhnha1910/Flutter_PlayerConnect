import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/draft_match_model.dart';
import '../../bloc/draft_match/draft_match_bloc.dart';
import '../../bloc/draft_match/draft_match_event.dart';
import '../../bloc/draft_match/draft_match_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../core/providers/websocket_provider.dart';
import '../../../core/providers/draft_match_subscription_provider.dart';
import '../../widgets/draft_match_card.dart';
import 'create_draft_match_screen.dart';
import '../explore/explore_screen.dart';
import '../main_navigation_screen.dart';

class DraftMatchListScreen extends StatefulWidget {
  const DraftMatchListScreen({super.key});

  @override
  State<DraftMatchListScreen> createState() => _DraftMatchListScreenState();
}

class _DraftMatchListScreenState extends State<DraftMatchListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedSport = 'All';
  final List<String> _sportTypes = [
    'All',
    'Football',
    'Basketball',
    'Tennis',
    'Badminton',
    'Volleyball',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);

    // Load initial data
    context.read<DraftMatchBloc>().add(FetchMyDraftMatches());

    // Setup WebSocket subscriptions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupWebSocketSubscriptions();
    });
  }

  void _setupWebSocketSubscriptions() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.id;

      // Subscribe to draft match updates
      context
          .read<DraftMatchSubscriptionProvider>()
          .subscribeToMultipleDraftMatches(
            [], // Will be populated when matches are loaded
          );

      // Listen to WebSocket streams for real-time updates
      context.read<WebSocketProvider>().draftMatchStream.listen((message) {
        _handleWebSocketMessage(message);
        _refreshCurrentTab();
      });
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final messageType = message['type'] as String?;
    final userName = message['userName'] as String? ?? 'Someone';

    String notificationText = '';

    switch (messageType) {
      case 'INTEREST_EXPRESSED':
        notificationText = '$userName expressed interest in a draft match';
        break;
      case 'INTEREST_WITHDRAWN':
        notificationText = '$userName withdrew interest from a draft match';
        break;
      case 'USER_APPROVED':
        notificationText = '$userName was approved for a draft match';
        break;
      case 'USER_REJECTED':
        notificationText = '$userName was rejected from a draft match';
        break;
      case 'DRAFT_MATCH_UPDATED':
        notificationText = 'Draft match was updated';
        break;
      default:
        return; // Don't show notification for unknown message types
    }

    if (notificationText.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(notificationText),
          duration: const Duration(seconds: 3),
          backgroundColor: AppTheme.primaryAccent,
        ),
      );
    }
  }

  void _refreshCurrentTab() {
    if (!mounted) return;

    switch (_tabController.index) {
      case 0:
        context.read<DraftMatchBloc>().add(FetchMyDraftMatches());
        break;
      case 1:
        context.read<DraftMatchBloc>().add(FetchPublicDraftMatches());
        break;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _refreshCurrentTab();
    }
  }

  List<DraftMatchModel> _filterDraftMatches(List<DraftMatchModel> matches) {
    return matches.where((match) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          match.locationDescription.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          match.sportType.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesSport =
          _selectedSport == 'All' || match.sportType == _selectedSport;

      return matchesSearch && matchesSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DraftMatchBloc, DraftMatchState>(
      listener: (context, state) {
        if (state is DraftMatchCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Draft match created successfully!')),
          );
          _refreshCurrentTab();
        } else if (state is InterestExpressed) {
          // Kiểm tra status để hiển thị message phù hợp
          final status = state.draftMatch.currentUserStatus;
          final message = status == 'PENDING' 
              ? 'Đã gửi yêu cầu tham gia! Đang chờ chủ kèo duyệt.'
              : 'Đã bày tỏ quan tâm thành công!';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
          _refreshCurrentTab();
        } else if (state is InterestWithdrawn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã rút khỏi kèo thành công!')),
          );
          _refreshCurrentTab();
        } else if (state is UserAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User accepted successfully!')),
          );
          _refreshCurrentTab();
        } else if (state is UserRejected) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User rejected successfully!')),
          );
          _refreshCurrentTab();
        } else if (state is DraftMatchConvertedSuccess) {
          _showConvertSuccessNotification(message: state.message);
          
          // Navigate to MainNavigationScreen with Explore tab immediately
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const MainNavigationScreen(
                initialTabIndex: 1, // Explore tab
              ),
            ),
          );
        } else if (state is DraftMatchError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.scaffoldBackground,
        appBar: AppBar(
          title: const Text(
            'Draft Matches',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppTheme.primaryAccent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                _showSearchDialog();
              },
            ),
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                _showFilterDialog();
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'My Matches'),
              Tab(text: 'Public'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDraftMatchList('my'),
            _buildDraftMatchList('public'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'draft_match_fab',
          backgroundColor: AppTheme.primaryAccent,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CreateDraftMatchScreen(),
              ),
            );
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildDraftMatchList(String listType) {
    return BlocBuilder<DraftMatchBloc, DraftMatchState>(
      builder: (context, state) {
        if (state is DraftMatchLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is DraftMatchListLoaded &&
            state.listType == listType) {
          final filteredMatches = _filterDraftMatches(state.draftMatches);

          if (filteredMatches.isEmpty) {
            return _buildEmptyState(listType);
          }

          return RefreshIndicator(
            onRefresh: () async {
              _refreshCurrentTab();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              itemCount: filteredMatches.length,
              itemBuilder: (context, index) {
                final draftMatch = filteredMatches[index];
                return BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    int? currentUserId;
                    if (authState is Authenticated) {
                      currentUserId = authState.user.id;
                    }

                    return DraftMatchCard(
                      draftMatch: draftMatch,
                      currentUserId: currentUserId,
                      isProcessing: state.isMatchProcessing(draftMatch.id),
                      onTap: () => _showDraftMatchDetails(draftMatch),
                      onExpressInterest: () => _expressInterest(draftMatch.id),
                      onWithdrawInterest: () =>
                          _withdrawInterest(draftMatch.id),
                      onApproveUser: (userId) =>
                          _approveUser(draftMatch.id, userId),
                      onRejectUser: (userId) =>
                          _rejectUser(draftMatch.id, userId),
                      onViewInterestedUsers: () =>
                          _viewInterestedUsers(draftMatch),
                      onConvertToMatch: () => _convertToMatch(draftMatch.id),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is DraftMatchError) {
          return _buildErrorState(state.message);
        }
        return _buildEmptyState(listType);
      },
    );
  }

  Widget _buildEmptyState(String listType) {
    String message;
    IconData icon;

    switch (listType) {
      case 'active':
        message = 'No active draft matches found';
        icon = Icons.sports_soccer;
        break;
      case 'my':
        message = 'You haven\'t created any draft matches yet';
        icon = Icons.person;
        break;
      case 'public':
        message = 'No public draft matches available';
        icon = Icons.public;
        break;
      default:
        message = 'No draft matches found';
        icon = Icons.search_off;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            message,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            'Pull to refresh or create a new draft match',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            'Something went wrong',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.errorColor),
          ),
          const SizedBox(height: AppTheme.spacingS),
          Text(
            message,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingM),
          ElevatedButton(
            onPressed: _refreshCurrentTab,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryAccent,
            ),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Draft Matches'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search by location or sport...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Sport'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _sportTypes.map((sport) {
            return RadioListTile<String>(
              title: Text(sport),
              value: sport,
              groupValue: _selectedSport,
              onChanged: (value) {
                setState(() {
                  _selectedSport = value!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showDraftMatchDetails(DraftMatchModel draftMatch) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          int? currentUserId;
          if (authState is Authenticated) {
            currentUserId = authState.user.id;
          }

          final bool isCreator =
              currentUserId != null &&
              currentUserId == draftMatch.creatorUserId;

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.textSecondary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      Text(
                        draftMatch.sportType,
                        style: AppTheme.headingMedium.copyWith(
                          color: AppTheme.primaryAccent,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingS),
                      Text(
                        draftMatch.locationDescription,
                        style: AppTheme.headingSmall,
                      ),
                      const SizedBox(height: AppTheme.spacingM),
                      _buildDetailRow(
                        Icons.schedule,
                        'Start Time',
                        '${draftMatch.estimatedStartTime.day.toString().padLeft(2, '0')}/${draftMatch.estimatedStartTime.month.toString().padLeft(2, '0')}/${draftMatch.estimatedStartTime.year} ${draftMatch.estimatedStartTime.hour.toString().padLeft(2, '0')}:${draftMatch.estimatedStartTime.minute.toString().padLeft(2, '0')}',
                      ),
                      _buildDetailRow(
                        Icons.schedule_outlined,
                        'End Time',
                        '${draftMatch.estimatedEndTime.day.toString().padLeft(2, '0')}/${draftMatch.estimatedEndTime.month.toString().padLeft(2, '0')}/${draftMatch.estimatedEndTime.year} ${draftMatch.estimatedEndTime.hour.toString().padLeft(2, '0')}:${draftMatch.estimatedEndTime.minute.toString().padLeft(2, '0')}',
                      ),
                      _buildDetailRow(
                        Icons.people,
                        'Slots Needed',
                        '${draftMatch.slotsNeeded}',
                      ),
                      _buildDetailRow(
                        Icons.star,
                        'Skill Level',
                        draftMatch.skillLevel,
                      ),
                      _buildDetailRow(
                        Icons.person,
                        'Creator',
                        draftMatch.creatorUserName,
                      ),
                      _buildDetailRow(
                        Icons.group,
                        'Interested Users',
                        '${draftMatch.interestedUsersCount}',
                      ),
                      _buildDetailRow(
                        Icons.check_circle,
                        'Approved Users',
                        '${draftMatch.approvedUsersCount}',
                      ),
                      const SizedBox(height: AppTheme.spacingL),
                      if (draftMatch.requiredTags.isNotEmpty) ...[
                        Text(
                          'Required Tags:',
                          style: AppTheme.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingS),
                        Wrap(
                          spacing: AppTheme.spacingS,
                          children: draftMatch.requiredTags.map((tag) {
                            return Chip(
                              label: Text(tag),
                              backgroundColor: AppTheme.primaryAccent
                                  .withOpacity(0.1),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppTheme.spacingL),
                      ],
                      Row(
                        children: [
                          if (!isCreator) ...[
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _expressInterest(draftMatch.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryAccent,
                                ),
                                child: const Text(
                                  'Express Interest',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacingM),
                          ],
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(isCreator ? 'Close' : 'Close'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spacingM),
          Text(
            '$label:',
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: AppTheme.spacingS),
          Expanded(child: Text(value, style: AppTheme.bodyMedium)),
        ],
      ),
    );
  }

  void _expressInterest(int draftMatchId) {
    context.read<DraftMatchBloc>().add(ExpressInterest(draftMatchId));
  }

  void _withdrawInterest(int draftMatchId) {
    context.read<DraftMatchBloc>().add(WithdrawInterest(draftMatchId));
  }

  void _approveUser(int draftMatchId, int userId) {
    context.read<DraftMatchBloc>().add(AcceptUser(draftMatchId, userId));
  }

  void _rejectUser(int draftMatchId, int userId) {
    context.read<DraftMatchBloc>().add(RejectUser(draftMatchId, userId));
  }

  void _viewInterestedUsers(DraftMatchModel draftMatch) {
    // Navigate to interested users screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Interested Users'),
            backgroundColor: AppTheme.primaryAccent,
            foregroundColor: Colors.white,
          ),
          body: Center(child: Text('Interested Users Screen\nComing Soon')),
        ),
      ),
    );
  }

  void _convertToMatch(int draftMatchId) {
    context.read<DraftMatchBloc>().add(ConvertToMatch(draftMatchId));
  }

  void _showConvertSuccessNotification({String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Draft match converted to match successfully!'),
        backgroundColor: AppTheme.primaryAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
