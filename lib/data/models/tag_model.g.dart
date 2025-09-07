// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TagModel _$TagModelFromJson(Map<String, dynamic> json) => TagModel(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  tagType: json['tagType'] as String,
  sportId: (json['sportId'] as num?)?.toInt(),
);

Map<String, dynamic> _$TagModelToJson(TagModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'tagType': instance.tagType,
  'sportId': instance.sportId,
};

TagRequest _$TagRequestFromJson(Map<String, dynamic> json) => TagRequest(
  tagId: (json['tagId'] as num?)?.toInt(),
  tagName: json['tagName'] as String,
  tagType: json['tagType'] as String,
);

Map<String, dynamic> _$TagRequestToJson(TagRequest instance) =>
    <String, dynamic>{
      'tagId': instance.tagId,
      'tagName': instance.tagName,
      'tagType': instance.tagType,
    };
