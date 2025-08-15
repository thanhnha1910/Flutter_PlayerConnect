import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
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
    {
      'id': 6,
      'type': 'match_joined',
      'userName': 'David Brown',
      'action': 'joined a football match at',
      'venue': 'Green Field Stadium',
      'time': '3 days ago',
      'avatar': 'DB',
    },
    {
      'id': 7,
      'type': 'milestone',
      'userName': 'Emma Davis',
      'action': 'reached a new milestone:',
      'milestone': 'First Victory!',
      'time': '4 days ago',
      'avatar': 'ED',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        title: Text(
          'Activity',
          style: AppTheme.headingMedium.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryAccent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        itemCount: communityFeed.length,
        itemBuilder: (context, index) {
          return _buildFeedItem(communityFeed[index]);
        },
      ),
    );
  }

  /// Builds a feed item
  Widget _buildFeedItem(Map<String, dynamic> feedItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: _getAvatarColor(feedItem['avatar']),
              child: Text(
                feedItem['avatar'],
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
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
                      style: AppTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: feedItem['userName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' ${feedItem['action']} ',
                        ),
                        if (feedItem['venue'] != null)
                          TextSpan(
                            text: feedItem['venue'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        if (feedItem['milestone'] != null)
                          TextSpan(
                            text: feedItem['milestone'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                        if (feedItem['teamName'] != null)
                          TextSpan(
                            text: feedItem['teamName'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryAccent,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: AppTheme.iconSizeSmall,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: AppTheme.spacingXS),
                      Text(
                        feedItem['time'],
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _getSportIcon(feedItem['type']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets avatar color based on initials
  Color _getAvatarColor(String initials) {
    final colors = [
      AppTheme.primaryAccent,
      AppTheme.secondaryAccent,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[initials.hashCode % colors.length];
  }

  /// Gets sport icon based on activity type
  Widget _getSportIcon(String type) {
    IconData iconData;
    Color iconColor = AppTheme.textSecondary;

    switch (type) {
      case 'match_joined':
      case 'match_created':
        iconData = Icons.sports_soccer;
        iconColor = AppTheme.primaryAccent;
        break;
      case 'milestone':
      case 'achievement':
        iconData = Icons.emoji_events;
        iconColor = Colors.amber.shade600;
        break;
      case 'team_formed':
        iconData = Icons.groups;
        iconColor = AppTheme.secondaryAccent;
        break;
      default:
        iconData = Icons.sports;
    }

    return Icon(
      iconData,
      size: AppTheme.iconSizeSmall,
      color: iconColor,
    );
  }
}