import 'package:json_annotation/json_annotation.dart';

part 'chatbot_models.g.dart';

@JsonSerializable()
class ChatbotRequestDTO {
  final String message;
  final String? sessionId;
  final Map<String, dynamic>? context;

  ChatbotRequestDTO({
    required this.message,
    this.sessionId,
    this.context,
  });

  factory ChatbotRequestDTO.fromJson(Map<String, dynamic> json) =>
      _$ChatbotRequestDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ChatbotRequestDTOToJson(this);
}

@JsonSerializable()
class ChatbotResponseDTO {
  final String text;
  final String? sessionId;
  final Map<String, dynamic>? context;
  final List<ActionDTO>? actions;

  ChatbotResponseDTO({
    required this.text,
    this.sessionId,
    this.context,
    this.actions,
  });

  factory ChatbotResponseDTO.fromJson(Map<String, dynamic> json) =>
      _$ChatbotResponseDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ChatbotResponseDTOToJson(this);

  // Helper method to get response text
  String get responseText => text;
}

@JsonSerializable()
class ActionDTO {
  final String label;
  final String type;
  final Map<String, dynamic> payload;

  ActionDTO({
    required this.label,
    required this.type,
    required this.payload,
  });

  factory ActionDTO.fromJson(Map<String, dynamic> json) =>
      _$ActionDTOFromJson(json);
  Map<String, dynamic> toJson() => _$ActionDTOToJson(this);
}