import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'open_match_model.g.dart';

// Enum cho trạng thái join của user
enum JoinStatus { NOT_JOINED, REQUEST_PENDING, JOINED }

@JsonSerializable(explicitToJson: true)
class OpenMatchModel extends Equatable {
  final int id;
  final int? bookingId; // Separate field for booking ID
  final String fieldName; // Deprecated: use locationName instead
  final String locationName;
  final String fieldAddress;
  final DateTime startTime;
  final DateTime endTime;
  final int currentPlayers; // Deprecated: use currentParticipants instead
  final int currentParticipants;
  final int maxPlayers; // Deprecated: use slotsNeeded instead
  final int slotsNeeded;
  final double pricePerPerson;
  final String? description;
  final String? fieldImageUrl;
  final double? aiCompatibilityScore;
  final double? compatibilityScore; // New field from FE
  final String organizerName; // Deprecated: use creatorUserName instead
  final String creatorUserName;
  final String? organizerAvatar; // Deprecated: use creatorAvatarUrl instead
  final String? creatorAvatarUrl;
  final List<String>? tags; // Deprecated: use requiredTags instead
  final List<String> requiredTags;
  final String skillLevel; // 'beginner', 'intermediate', 'advanced'
  final String gameType; // 'football', 'basketball', etc.
  final JoinStatus currentUserJoinStatus;
  final String? creatorUserId;
  final bool isCreator;

  OpenMatchModel({
    required this.id,
    this.bookingId,
    String? fieldName,
    String? locationName,
    required this.fieldAddress,
    required this.startTime,
    required this.endTime,
    int? currentPlayers,
    int? currentParticipants,
    int? maxPlayers,
    int? slotsNeeded,
    required this.pricePerPerson,
    this.description,
    this.fieldImageUrl,
    this.aiCompatibilityScore,
    this.compatibilityScore,
    String? organizerName,
    String? creatorUserName,
    String? organizerAvatar,
    String? creatorAvatarUrl,
    List<String>? tags,
    List<String>? requiredTags,
    this.skillLevel = 'intermediate',
    this.gameType = 'football',
    this.currentUserJoinStatus = JoinStatus.NOT_JOINED,
    this.creatorUserId,
    this.isCreator = false,
  }) : fieldName = fieldName ?? locationName ?? '',
       locationName = locationName ?? fieldName ?? '',
       currentPlayers = currentPlayers ?? currentParticipants ?? 0,
       currentParticipants = currentParticipants ?? currentPlayers ?? 0,
       maxPlayers = maxPlayers ?? slotsNeeded ?? 0,
       slotsNeeded = slotsNeeded ?? maxPlayers ?? 0,
       organizerName = organizerName ?? creatorUserName ?? 'Unknown',
       creatorUserName = creatorUserName ?? organizerName ?? 'Unknown',
       organizerAvatar = organizerAvatar ?? creatorAvatarUrl,
       creatorAvatarUrl = creatorAvatarUrl ?? organizerAvatar,
       tags = tags ?? requiredTags ?? [],
       requiredTags = requiredTags ?? tags ?? <String>[];

  // Map sport type từ backend format sang frontend format
  static String _mapSportType(String? sportType) {
    if (sportType == null) return 'football';

    switch (sportType.toUpperCase()) {
      case 'BONG_DA':
      case 'FOOTBALL':
        return 'football';
      case 'BONG_RO':
      case 'BASKETBALL':
        return 'basketball';
      case 'TENNIS':
        return 'tennis';
      case 'BADMINTON':
        return 'badminton';
      default:
        return sportType.toLowerCase();
    }
  }

  factory OpenMatchModel.fromJson(
    Map<String, dynamic> json, {
    String? currentUserId,
  }) {
    // Parse join status từ string
    JoinStatus parseJoinStatus(String? status) {
      print('DEBUG: Parsing join status: "$status"');
      switch (status?.toUpperCase()) {
        case 'JOINED':
        case 'ACCEPTED':
          return JoinStatus.JOINED;
        case 'PENDING':
        case 'REQUEST_PENDING':
          return JoinStatus.REQUEST_PENDING;
        default:
          return JoinStatus.NOT_JOINED;
      }
    }

    final creatorUserId =
        (json['creatorUserId'] ?? json['creator_user_id'] ?? json['createdBy'])
            ?.toString();
    final isCreator = currentUserId != null && creatorUserId != null
        ? creatorUserId == currentUserId
        : (json['isCreator'] ?? json['is_creator'] ?? false);

    return OpenMatchModel(
      id: json['id'] ?? json['bookingId'] ?? 0,
      bookingId: json['bookingId'],
      fieldName: json['fieldName'],
      locationName: json['locationName'] ?? json['fieldName'] ?? '',
      fieldAddress: json['locationAddress'] ?? json['locationName'] ?? '',
      startTime: DateTime.parse(
        json['startTime'] ?? DateTime.now().toIso8601String(),
      ),
      endTime: DateTime.parse(
        json['endTime'] ?? DateTime.now().toIso8601String(),
      ),
      currentPlayers: json['currentPlayers'],
      currentParticipants:
          json['currentParticipants'] ?? json['currentPlayers'] ?? 0,
      maxPlayers: json['maxPlayers'],
      slotsNeeded:
          json['slotsNeeded'] ??
          json['maxPlayers'] ??
          ((json['currentParticipants'] ?? 0) + 1),
      pricePerPerson:
          (json['pricePerPerson'] ?? json['price_per_person'] ?? 50.0)
              .toDouble(),
      description: json['description'] ?? json['requiredTags']?.join(', '),
      fieldImageUrl: json['fieldImageUrl'] ?? json['field_image_url'],
      aiCompatibilityScore: json['aiCompatibilityScore']?.toDouble(),
      compatibilityScore:
          json['compatibilityScore']?.toDouble() ??
          json['aiCompatibilityScore']?.toDouble(),
      organizerName: json['organizerName'],
      creatorUserName:
          json['creatorUserName'] ?? json['organizerName'] ?? 'Unknown',
      organizerAvatar: json['organizerAvatar'],
      creatorAvatarUrl: json['creatorAvatarUrl'] ?? json['organizerAvatar'],
      tags: json['tags']?.cast<String>(),
      requiredTags:
          (json['requiredTags'] as List?)?.cast<String>() ??
          (json['tags'] as List?)?.cast<String>() ??
          [],
      skillLevel: json['skillLevel'] ?? json['skill_level'] ?? 'intermediate',
      gameType:
          json['gameType'] ?? _mapSportType(json['sportType']) ?? 'football',
      currentUserJoinStatus: parseJoinStatus(
        json['currentUserJoinStatus'] ??
            json['current_user_join_status'] ??
            json['joinStatus'],
      ),
      creatorUserId: creatorUserId,
      isCreator: isCreator,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldName': fieldName,
      'fieldAddress': fieldAddress,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'currentPlayers': currentPlayers,
      'maxPlayers': maxPlayers,
      'pricePerPerson': pricePerPerson,
      'description': description,
      'fieldImageUrl': fieldImageUrl,
      'organizerName': organizerName,
      'organizerAvatar': organizerAvatar,
      'tags': tags,
      'skillLevel': skillLevel,
      'gameType': gameType,
      'aiCompatibilityScore': aiCompatibilityScore,
      'currentUserJoinStatus': currentUserJoinStatus.name,
      'creatorUserId': creatorUserId,
      'isCreator': isCreator,
    };
  }

  int get playersNeeded => maxPlayers - currentPlayers;

  String get timeRange {
    final start =
        '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end =
        '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get skillLevelDisplay {
    switch (skillLevel) {
      case 'beginner':
        return 'Người mới';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Nâng cao';
      default:
        return 'Trung bình';
    }
  }

  @override
  List<Object?> get props => [
    id,
    bookingId,
    fieldName,
    fieldAddress,
    startTime,
    endTime,
    currentPlayers,
    maxPlayers,
    pricePerPerson,
    description,
    fieldImageUrl,
    aiCompatibilityScore,
    organizerName,
    organizerAvatar,
    tags,
    skillLevel,
    gameType,
    currentUserJoinStatus,
    creatorUserId,
    isCreator,
  ];
}
