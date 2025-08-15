import 'package:json_annotation/json_annotation.dart';

part 'chat_message_model.g.dart';

// Alias để tương thích với các file khác
typedef ChatMessage = ChatMessageModel;

@JsonSerializable()
class ChatMessageModel {
  final int? id;
  @JsonKey(name: 'userId')
  final int? userId;
  final String? username;
  final String? content;
  @JsonKey(name: 'sentAt')
  final DateTime? sentAt;

  const ChatMessageModel({
    this.id,
    this.userId,
    this.username,
    this.content,
    this.sentAt,
  });
  
  // Getter aliases để tương thích
  String get text => content ?? '';
  DateTime get timestamp => sentAt ?? DateTime.now();
  DateTime get createdAt => sentAt ?? DateTime.now();

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageModelToJson(this);
}