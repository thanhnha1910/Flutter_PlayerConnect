import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../widgets/open_match_card.dart';
import '../../../data/models/open_match_model.dart';
import '../../../core/services/ai_recommendation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/di/injection.dart';

class OpenMatchListScreen extends StatefulWidget {
  const OpenMatchListScreen({super.key});

  @override
  State<OpenMatchListScreen> createState() => _OpenMatchListScreenState();
}

class _OpenMatchListScreenState extends State<OpenMatchListScreen> {
  final AIRecommendationService _aiService = getIt<AIRecommendationService>();
  List<OpenMatchModel> _openMatches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOpenMatches();
  }

  Future<void> _loadOpenMatches() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Fetch real data from API using AIRecommendationService
      final matches = await _aiService.getOpenMatches();

      setState(() {
        _openMatches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load open matches: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshMatches() async {
    await _loadOpenMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Match'),
        backgroundColor: AppTheme.primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMatches,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshMatches,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_openMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text('No open matches available', style: AppTheme.headingSmall),
            const SizedBox(height: 8),
            Text(
              'Check back later for new matches',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshMatches,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMatches,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _openMatches.length,
        itemBuilder: (context, index) {
          final match = _openMatches[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OpenMatchCard(openMatch: match, onRefresh: _refreshMatches),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays} day(s) from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour(s) from now';
    } else {
      return '${difference.inMinutes} minute(s) from now';
    }
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0)} VND';
  }
}
