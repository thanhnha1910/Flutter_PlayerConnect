// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chatbot_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatbotRequestDTO _$ChatbotRequestDTOFromJson(Map<String, dynamic> json) =>
    ChatbotRequestDTO(
      message: json['message'] as String,
      sessionId: json['sessionId'] as String?,
      context: json['context'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ChatbotRequestDTOToJson(ChatbotRequestDTO instance) =>
    <String, dynamic>{
      'message': instance.message,
      'sessionId': instance.sessionId,
      'context': instance.context,
    };

ChatbotResponseDTO _$ChatbotResponseDTOFromJson(Map<String, dynamic> json) =>
    ChatbotResponseDTO(
      text: json['text'] as String,
      sessionId: json['sessionId'] as String?,
      context: json['context'] as Map<String, dynamic>?,
      actions: (json['actions'] as List<dynamic>?)
          ?.map((e) => ActionDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatbotResponseDTOToJson(ChatbotResponseDTO instance) =>
    <String, dynamic>{
      'text': instance.text,
      'sessionId': instance.sessionId,
      'context': instance.context,
      'actions': instance.actions,
    };

ActionDTO _$ActionDTOFromJson(Map<String, dynamic> json) => ActionDTO(
  label: json['label'] as String,
  type: json['type'] as String,
  payload: json['payload'] as Map<String, dynamic>,
);

Map<String, dynamic> _$ActionDTOToJson(ActionDTO instance) => <String, dynamic>{
  'label': instance.label,
  'type': instance.type,
  'payload': instance.payload,
};
