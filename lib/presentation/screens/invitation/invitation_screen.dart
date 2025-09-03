import 'package:flutter/material.dart';
import 'dart:async';
import '../../widgets/invitation_card.dart';
import '../../../data/models/invitation_model.dart';
import '../../../data/datasources/invitation_remote_datasource.dart';
import '../../../data/repositories/invitation_repository_impl.dart';
import '../../../core/network/api_client.dart';
import '../../../core/di/injection.dart';
import '../../../core/providers/websocket_provider.dart';

class InvitationScreen extends StatefulWidget {
  const InvitationScreen({Key? key}) : super(key: key);

  @override
  State<InvitationScreen> createState() => _InvitationScreenState();
}

class _InvitationScreenState extends State<InvitationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late InvitationRepositoryImpl _invitationRepository;
  late WebSocketProvider _webSocketProvider;
  StreamSubscription<Map<String, dynamic>>? _invitationSubscription;
  StreamSubscription<Map<String, dynamic>>? _draftMatchSubscription;

  List<InvitationModel> _receivedInvitations = [];
  List<InvitationModel> _sentInvitations = [];
  List<DraftMatchRequestModel> _receivedRequests = [];
  List<DraftMatchRequestModel> _sentRequests = [];

  bool _isLoadingReceived = false;
  bool _isLoadingSent = false;
  String? _errorMessage;
  
  // Debouncing timers to prevent excessive API calls
  Timer? _refreshInvitationsTimer;
  Timer? _refreshRequestsTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize repository using dependency injection
    final apiClient = getIt<ApiClient>();
    final remoteDataSource = InvitationRemoteDataSourceImpl(apiClient.dio);
    _invitationRepository = InvitationRepositoryImpl(remoteDataSource);

    // Initialize WebSocket provider
    _webSocketProvider = getIt<WebSocketProvider>();

    _loadData();
    _setupWebSocketSubscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invitationSubscription?.cancel();
    _draftMatchSubscription?.cancel();
    _refreshInvitationsTimer?.cancel();
    _refreshRequestsTimer?.cancel();
    super.dispose();
  }

  void _setupWebSocketSubscription() {
    // Listen to invitation stream for real-time updates
    _invitationSubscription = _webSocketProvider.invitationStream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('WebSocket invitation stream error: $error');
      },
    );
    
    // Listen to draft match stream for real-time updates
    _draftMatchSubscription = _webSocketProvider.draftMatchStream.listen(
      (message) {
        _handleWebSocketMessage(message);
      },
      onError: (error) {
        print('WebSocket draft match stream error: $error');
      },
    );
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    if (!mounted) return;
    
    try {
      final type = message['type'] as String?;
      final data = message['data'] as Map<String, dynamic>?;

      if (data == null) return;

      switch (type) {
        case 'INVITATION_RECEIVED':
        case 'INVITATION_UPDATED':
        case 'INVITATION_ACCEPTED':
        case 'INVITATION_REJECTED':
          _debouncedRefreshInvitations();
          break;
        case 'DRAFT_MATCH_REQUEST_RECEIVED':
        case 'DRAFT_MATCH_REQUEST_UPDATED':
        case 'DRAFT_MATCH_REQUEST_ACCEPTED':
        case 'DRAFT_MATCH_REQUEST_REJECTED':
          _debouncedRefreshRequests();
          break;
        default:
          print('Unknown invitation WebSocket message type: $type');
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }
  
  void _debouncedRefreshInvitations() {
    _refreshInvitationsTimer?.cancel();
    _refreshInvitationsTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _refreshInvitations();
      }
    });
  }
  
  void _debouncedRefreshRequests() {
    _refreshRequestsTimer?.cancel();
    _refreshRequestsTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        _refreshDraftMatchRequests();
      }
    });
  }

  Future<void> _refreshInvitations() async {
    try {
      final results = await Future.wait([
        _invitationRepository.getReceivedInvitations(),
        _invitationRepository.getSentInvitations(),
      ]);

      if (mounted) {
        setState(() {
          // Handle Either<Failure, InvitationListResponse> properly
          results[0].fold(
            (failure) =>
                print('Error loading received invitations: ${failure.message}'),
            (response) => _receivedInvitations =
                (response as InvitationListResponse).invitations,
          );
          results[1].fold(
            (failure) =>
                print('Error loading sent invitations: ${failure.message}'),
            (response) => _sentInvitations =
                (response as InvitationListResponse).invitations,
          );
        });
      }
    } catch (e) {
      print('Error refreshing invitations: $e');
    }
  }

  Future<void> _refreshDraftMatchRequests() async {
    try {
      final results = await Future.wait([
        _invitationRepository.getReceivedDraftMatchRequests(),
        _invitationRepository.getSentDraftMatchRequests(),
      ]);

      if (mounted) {
        setState(() {
          // Handle Either<Failure, DraftMatchRequestListResponse> properly
          results[0].fold(
            (failure) =>
                print('Error loading received requests: ${failure.message}'),
            (response) => _receivedRequests =
                (response as DraftMatchRequestListResponse).requests,
          );
          results[1].fold(
            (failure) =>
                print('Error loading sent requests: ${failure.message}'),
            (response) => _sentRequests =
                (response as DraftMatchRequestListResponse).requests,
          );
        });
      }
    } catch (e) {
      print('Error refreshing draft match requests: $e');
    }
  }

  Future<void> _loadData() async {
    await Future.wait([_loadReceivedData(), _loadSentData()]);
  }

  Future<void> _loadReceivedData() async {
    setState(() {
      _isLoadingReceived = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _invitationRepository.getReceivedInvitations(),
        _invitationRepository.getReceivedDraftMatchRequests(),
      ]);

      setState(() {
        // Handle Either types properly
        results[0].fold(
          (failure) {
            _errorMessage = 'Lỗi tải lời mời: ${failure.message}';
            _receivedInvitations = [];
          },
          (response) => _receivedInvitations =
              (response as InvitationListResponse).invitations,
        );
        results[1].fold(
          (failure) {
            _errorMessage = 'Lỗi tải yêu cầu: ${failure.message}';
            _receivedRequests = [];
          },
          (response) => _receivedRequests =
              (response as DraftMatchRequestListResponse).requests,
        );
        _isLoadingReceived = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoadingReceived = false;
      });
    }
  }

  Future<void> _loadSentData() async {
    setState(() {
      _isLoadingSent = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _invitationRepository.getSentInvitations(),
        _invitationRepository.getSentDraftMatchRequests(),
      ]);

      setState(() {
        // Handle Either types properly
        results[0].fold(
          (failure) {
            _errorMessage = 'Lỗi tải lời mời đã gửi: ${failure.message}';
            _sentInvitations = [];
          },
          (response) => _sentInvitations =
              (response as InvitationListResponse).invitations,
        );
        results[1].fold(
          (failure) {
            _errorMessage = 'Lỗi tải yêu cầu đã gửi: ${failure.message}';
            _sentRequests = [];
          },
          (response) => _sentRequests =
              (response as DraftMatchRequestListResponse).requests,
        );
        _isLoadingSent = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể tải dữ liệu: $e';
        _isLoadingSent = false;
      });
    }
  }

  Future<void> _handleInvitationAction(
    InvitationModel invitation,
    String action,
  ) async {
    try {
      final request = InvitationActionRequest(action: action);

      final result = await _invitationRepository.respondToInvitation(
        invitation.id,
        request,
      );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                action == 'ACCEPT'
                    ? 'Đã chấp nhận lời mời'
                    : 'Đã từ chối lời mời',
              ),
              backgroundColor: action == 'ACCEPT' ? Colors.green : Colors.red,
            ),
          );

          // Reload data
          _loadReceivedData();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleRequestAction(
    DraftMatchRequestModel request,
    String action,
  ) async {
    try {
      final result = action == 'ACCEPT'
          ? await _invitationRepository.acceptDraftMatchRequest(
              request.draftMatch.id,
              request.user.id,
            )
          : await _invitationRepository.rejectDraftMatchRequest(
              request.draftMatch.id,
              request.user.id,
            );

      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                action == 'ACCEPT' ? 'Đã chấp nhận yêu cầu' : 'Đã từ chối yêu cầu',
              ),
              backgroundColor: action == 'ACCEPT' ? Colors.green : Colors.red,
            ),
          );

          // Reload data only on success
          _loadReceivedData();
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lời mời & Yêu cầu'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inbox), text: 'Đã nhận'),
            Tab(icon: Icon(Icons.send), text: 'Đã gửi'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildReceivedTab(), _buildSentTab()],
      ),
    );
  }

  Widget _buildReceivedTab() {
    if (_isLoadingReceived) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReceivedData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final allReceivedItems = <Widget>[];

    // Add invitations
    for (final invitation in _receivedInvitations) {
      allReceivedItems.add(
        InvitationCard(
          invitation: invitation,
          isReceived: true,
          onAccept: invitation.isPending
              ? () => _handleInvitationAction(invitation, 'ACCEPT')
              : null,
          onReject: invitation.isPending
              ? () => _handleInvitationAction(invitation, 'REJECT')
              : null,
        ),
      );
    }

    // Add draft match requests
    for (final request in _receivedRequests) {
      allReceivedItems.add(
        InvitationCard(
          draftMatchRequest: request,
          isReceived: true,
          onAccept: request.isPending
              ? () => _handleRequestAction(request, 'ACCEPT')
              : null,
          onReject: request.isPending
              ? () => _handleRequestAction(request, 'REJECT')
              : null,
        ),
      );
    }

    if (allReceivedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có lời mời nào',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Các lời mời và yêu cầu tham gia sẽ hiển thị ở đây',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReceivedData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: allReceivedItems,
      ),
    );
  }

  Widget _buildSentTab() {
    if (_isLoadingSent) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSentData,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    final allSentItems = <Widget>[];

    // Add sent invitations
    for (final invitation in _sentInvitations) {
      allSentItems.add(
        InvitationCard(invitation: invitation, isReceived: false),
      );
    }

    // Add sent draft match requests
    for (final request in _sentRequests) {
      allSentItems.add(
        InvitationCard(draftMatchRequest: request, isReceived: false),
      );
    }

    if (allSentItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa gửi lời mời nào',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Các lời mời và yêu cầu bạn đã gửi sẽ hiển thị ở đây',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSentData,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: allSentItems,
      ),
    );
  }
}
