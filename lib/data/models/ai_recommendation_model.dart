class RecommendedPlayerModel {
  final String id;
  final String name;
  final String? avatar;
  final String email;
  final double compatibilityScore;
  final List<String> tags;
  final String? location;
  final int? age;
  final String? skillLevel;
  final bool isOnline;
  final DateTime? lastActive;

  const RecommendedPlayerModel({
    required this.id,
    required this.name,
    this.avatar,
    required this.email,
    required this.compatibilityScore,
    required this.tags,
    this.location,
    this.age,
    this.skillLevel,
    required this.isOnline,
    this.lastActive,
  });

  factory RecommendedPlayerModel.fromJson(Map<String, dynamic> json) {
    return RecommendedPlayerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
      email: json['email'] as String,
      compatibilityScore: (json['compatibilityScore'] as num).toDouble(),
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] as String?,
      age: json['age'] as int?,
      skillLevel: json['skillLevel'] as String?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastActive: json['lastActive'] != null 
          ? DateTime.parse(json['lastActive'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'email': email,
      'compatibilityScore': compatibilityScore,
      'tags': tags,
      'location': location,
      'age': age,
      'skillLevel': skillLevel,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecommendedPlayerModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class OpenMatchModel {
  final String id;
  final String title;
  final String description;
  final DateTime matchTime;
  final String location;
  final String fieldType;
  final int maxPlayers;
  final int currentPlayers;
  final double pricePerPlayer;
  final String creatorId;
  final String creatorName;
  final String? creatorAvatar;
  final List<String> tags;
  final String status;
  final DateTime createdAt;
  final List<String> joinedPlayerIds;
  final bool isPublic;
  final String? skillLevelRequired;

  const OpenMatchModel({
    required this.id,
    required this.title,
    required this.description,
    required this.matchTime,
    required this.location,
    required this.fieldType,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.pricePerPlayer,
    required this.creatorId,
    required this.creatorName,
    this.creatorAvatar,
    required this.tags,
    required this.status,
    required this.createdAt,
    required this.joinedPlayerIds,
    required this.isPublic,
    this.skillLevelRequired,
  });

  factory OpenMatchModel.fromJson(Map<String, dynamic> json) {
    return OpenMatchModel(
      id: json['id'].toString(),
      title: json['fieldName'] as String? ?? 'Open Match',
      description: json['requiredTags'] != null 
          ? 'Required tags: ${(json['requiredTags'] as List).join(', ')}'
          : 'Open match available',
      matchTime: DateTime.parse(json['startTime'] as String),
      location: json['locationName'] as String? ?? json['locationAddress'] as String? ?? 'Unknown location',
      fieldType: json['sportType'] as String? ?? 'Unknown',
      maxPlayers: (json['slotsNeeded'] as int? ?? 1) + (json['currentParticipants'] as int? ?? 0),
      currentPlayers: json['currentParticipants'] as int? ?? 0,
      pricePerPlayer: 0.0, // Not provided in API response
      creatorId: json['creatorUserId'].toString(),
      creatorName: json['creatorUserName'] as String? ?? 'Unknown',
      creatorAvatar: json['creatorAvatarUrl'] as String?,
      tags: json['requiredTags'] != null 
          ? List<String>.from(json['requiredTags'])
          : [],
      status: (json['status'] as String? ?? 'OPEN').toLowerCase(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      joinedPlayerIds: json['participantIds'] != null 
          ? List<String>.from(json['participantIds'].map((id) => id.toString()))
          : [],
      isPublic: true, // Assuming all open matches are public
      skillLevelRequired: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'matchTime': matchTime.toIso8601String(),
      'location': location,
      'fieldType': fieldType,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'pricePerPlayer': pricePerPlayer,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorAvatar': creatorAvatar,
      'tags': tags,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'joinedPlayerIds': joinedPlayerIds,
      'isPublic': isPublic,
      'skillLevelRequired': skillLevelRequired,
    };
  }

  bool get isFull => currentPlayers >= maxPlayers;
  bool get canJoin => !isFull && status == 'ACTIVE';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenMatchModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class AIRecommendationResponse {
  final List<RecommendedPlayerModel> recommendedPlayers;
  final List<OpenMatchModel> suggestedMatches;
  final String? message;
  final bool success;
  final DateTime timestamp;

  const AIRecommendationResponse({
    required this.recommendedPlayers,
    required this.suggestedMatches,
    this.message,
    required this.success,
    required this.timestamp,
  });

  factory AIRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return AIRecommendationResponse(
      recommendedPlayers: (json['recommendedPlayers'] as List<dynamic>? ?? [])
          .map((player) => RecommendedPlayerModel.fromJson(player as Map<String, dynamic>))
          .toList(),
      suggestedMatches: (json['suggestedMatches'] as List<dynamic>? ?? [])
          .map((match) => OpenMatchModel.fromJson(match as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
      success: json['success'] as bool? ?? true,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedPlayers': recommendedPlayers.map((player) => player.toJson()).toList(),
      'suggestedMatches': suggestedMatches.map((match) => match.toJson()).toList(),
      'message': message,
      'success': success,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  bool get hasRecommendations => recommendedPlayers.isNotEmpty || suggestedMatches.isNotEmpty;
}

// Invitation model for sending invites to recommended players
class PlayerInvitationModel {
  final String id;
  final String bookingId;
  final String inviterId;
  final String inviteeId;
  final String message;
  final String status; // PENDING, ACCEPTED, DECLINED
  final DateTime createdAt;
  final DateTime? respondedAt;

  const PlayerInvitationModel({
    required this.id,
    required this.bookingId,
    required this.inviterId,
    required this.inviteeId,
    required this.message,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory PlayerInvitationModel.fromJson(Map<String, dynamic> json) {
    return PlayerInvitationModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      inviterId: json['inviterId'] as String,
      inviteeId: json['inviteeId'] as String,
      message: json['message'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'inviterId': inviterId,
      'inviteeId': inviteeId,
      'message': message,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isAccepted => status == 'ACCEPTED';
  bool get isDeclined => status == 'DECLINED';
}