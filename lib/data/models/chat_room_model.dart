import 'package:json_annotation/json_annotation.dart';

part 'chat_room_model.g.dart';

@JsonSerializable()
class ChatRoomModel {
  final int id;
  final String name;
  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;
  @JsonKey(name: 'lastMessage')
  final String? lastMessage;
  @JsonKey(name: 'lastMessageTime')
  final DateTime? lastMessageTime;
  @JsonKey(name: 'memberCount')
  final int memberCount;

  const ChatRoomModel({
    required this.id,
    required this.name,
    this.createdAt,
    this.lastMessage,
    this.lastMessageTime,
    this.memberCount = 0,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomModelToJson(this);
}