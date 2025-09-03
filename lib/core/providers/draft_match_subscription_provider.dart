import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/websocket_service.dart';
import '../../data/models/draft_match_model.dart';

/// Provider for managing draft match WebSocket subscriptions
/// Equivalent to useDraftMatchSubscriptions.js in FE
class DraftMatchSubscriptionProvider extends ChangeNotifier {
  final WebSocketService _webSocketService;
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, DraftMatchModel> _draftMatches = {};
  
  StreamSubscription? _generalSubscription;
  StreamSubscription? _interestSubscription;
  
  DraftMatchSubscriptionProvider(this._webSocketService) {
    _setupGeneralSubscriptions();
  }

  /// Get all cached draft matches
  Map<String, DraftMatchModel> get draftMatches => Map.unmodifiable(_draftMatches);

  /// Get a specific draft match by ID
  DraftMatchModel? getDraftMatch(String id) => _draftMatches[id];

  /// Subscribe to multiple draft matches
  void subscribeToMultipleDraftMatches(List<DraftMatchModel> draftMatches) {
    if (!_webSocketService.isConnected) {
      debugPrint('❌ Cannot subscribe to draft matches: WebSocket not connected');
      return;
    }

    // Clear existing subscriptions
    _clearDraftMatchSubscriptions();

    // Subscribe to each draft match
    for (final draftMatch in draftMatches) {
      _subscribeToDraftMatch(draftMatch.id.toString());
      _draftMatches[draftMatch.id.toString()] = draftMatch;
    }

    notifyListeners();
  }

  /// Subscribe to a single draft match
  void subscribeToDraftMatch(String draftMatchId) {
    if (!_webSocketService.isConnected) {
      debugPrint('❌ Cannot subscribe to draft match: WebSocket not connected');
      return;
    }

    _subscribeToDraftMatch(draftMatchId);
  }

  /// Internal method to subscribe to a draft match
  void _subscribeToDraftMatch(String draftMatchId) {
    final subscriptionKey = 'draft_match_$draftMatchId';
    
    // Unsubscribe if already subscribed
    _subscriptions[subscriptionKey]?.cancel();
    
    // Subscribe to draft match updates
    _webSocketService.subscribeToDraftMatch(draftMatchId);
    
    // Listen to the draft match stream
    final subscription = _webSocketService.draftMatchStream.listen(
      (data) {
        try {
          final updatedDraftMatch = DraftMatchModel.fromJson(data);
          
          if (updatedDraftMatch.id == draftMatchId) {
            debugPrint('📱 Draft match update received for: $draftMatchId');
            
            // Update cached draft match
            _draftMatches[draftMatchId] = updatedDraftMatch;
            
            // Notify listeners with a small delay to allow UI events to render first
            Future.delayed(const Duration(milliseconds: 100), () {
              notifyListeners();
            });
          }
        } catch (e) {
          debugPrint('❌ Error parsing draft match update: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ Error in draft match subscription: $error');
      },
    );
    
    _subscriptions[subscriptionKey] = subscription;
    debugPrint('📱 Subscribed to draft match updates: $draftMatchId');
  }

  /// Setup general subscriptions for draft match interest updates
  void _setupGeneralSubscriptions() {
    // Subscribe to draft match interest updates
    _interestSubscription = _webSocketService.draftMatchStream.listen(
      (data) {
        try {
          // Handle draft match interest updates
            if (data['type'] == 'INTEREST_UPDATE') {
              final draftMatchId = data['draftMatchId']?.toString();
              final action = data['action'] as String?;
              final interestedUsersCount = data['interestedUsersCount'] as int?;
              final userId = data['user']?['id']?.toString();
              
              if (draftMatchId != null && _draftMatches.containsKey(draftMatchId)) {
                // Since DraftMatchModel doesn't have copyWith, we'll create a new instance
                // For now, we'll just update the cache with the new data from the stream
                // The actual update will come through the regular draft match stream
                
                debugPrint('📱 Draft match $draftMatchId interest update: $action');
                
                // Notify listeners with delay
                Future.delayed(const Duration(milliseconds: 100), () {
                  notifyListeners();
                });
              }
            }
        } catch (e) {
          debugPrint('❌ Error parsing draft match interest update: $e');
        }
      },
      onError: (error) {
        debugPrint('❌ Error in draft match interest subscription: $error');
      },
    );
  }

  /// Unsubscribe from a specific draft match
  void unsubscribeFromDraftMatch(String draftMatchId) {
    final subscriptionKey = 'draft_match_$draftMatchId';
    _subscriptions[subscriptionKey]?.cancel();
    _subscriptions.remove(subscriptionKey);
    _draftMatches.remove(draftMatchId);
    
    debugPrint('📱 Unsubscribed from draft match: $draftMatchId');
    notifyListeners();
  }

  /// Clear all draft match subscriptions
  void _clearDraftMatchSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _draftMatches.clear();
  }

  /// Update a draft match in the cache
  void updateDraftMatch(DraftMatchModel draftMatch) {
    _draftMatches[draftMatch.id.toString()] = draftMatch;
    notifyListeners();
  }

  /// Remove a draft match from the cache
  void removeDraftMatch(int draftMatchId) {
    final key = draftMatchId.toString();
    _draftMatches.remove(key);
    unsubscribeFromDraftMatch(key);
  }

  @override
  void dispose() {
    _clearDraftMatchSubscriptions();
    _generalSubscription?.cancel();
    _interestSubscription?.cancel();
    super.dispose();
  }
}