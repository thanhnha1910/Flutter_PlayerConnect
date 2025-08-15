// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jwt_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JwtResponseModel _$JwtResponseModelFromJson(Map<String, dynamic> json) =>
    JwtResponseModel(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      type: json['type'] as String,
      id: (json['id'] as num).toInt(),
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      status: json['status'] as String,
      hasCompletedProfile: json['hasCompletedProfile'] as bool,
    );

Map<String, dynamic> _$JwtResponseModelToJson(JwtResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'refreshToken': instance.refreshToken,
      'type': instance.type,
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'fullName': instance.fullName,
      'roles': instance.roles,
      'status': instance.status,
      'hasCompletedProfile': instance.hasCompletedProfile,
    };
