import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

part 'open_match_model.g.dart';

@JsonSerializable(explicitToJson: true)
class OpenMatchModel extends Equatable {
  final int id;
  final String fieldName;
  final String fieldAddress;
  final DateTime startTime;
  final DateTime endTime;
  final int currentPlayers;
  final int maxPlayers;
  final double pricePerPerson;
  final String? description;
  final String? fieldImageUrl;
  final double? aiCompatibilityScore;
  final String organizerName;
  final String? organizerAvatar;
  final List<String>? tags;
  final String skillLevel; // 'beginner', 'intermediate', 'advanced'
  final String gameType; // 'football', 'basketball', etc.

  const OpenMatchModel({
    required this.id,
    required this.fieldName,
    required this.fieldAddress,
    required this.startTime,
    required this.endTime,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.pricePerPerson,
    this.description,
    this.fieldImageUrl,
    this.aiCompatibilityScore,
    required this.organizerName,
    this.organizerAvatar,
    this.tags,
    this.skillLevel = 'intermediate',
    this.gameType = 'football',
  });

  factory OpenMatchModel.fromJson(Map<String, dynamic> json) =>
      _$OpenMatchModelFromJson(json);

  Map<String, dynamic> toJson() => _$OpenMatchModelToJson(this);

  int get playersNeeded => maxPlayers - currentPlayers;

  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
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
      ];
}
