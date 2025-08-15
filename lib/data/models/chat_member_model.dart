import 'package:json_annotation/json_annotation.dart';

part 'chat_member_model.g.dart';

@JsonSerializable()
class ChatMemberModel {
  final int id;
  @JsonKey(name: 'userId')
  final int userId;
  final String username;
  final String? email;
  final String? fullName;
  @JsonKey(name: 'isAdmin')
  final bool isAdmin;
  @JsonKey(name: 'isCreator')
  final bool isCreator;
  @JsonKey(name: 'isActive')
  final bool isActive;
  @JsonKey(name: 'joinedAt')
  final DateTime joinedAt;

  const ChatMemberModel({
    required this.id,
    required this.userId,
    required this.username,
    this.email,
    this.fullName,
    required this.isAdmin,
    required this.isCreator,
    required this.isActive,
    required this.joinedAt,
  });

  factory ChatMemberModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMemberModelToJson(this);
}