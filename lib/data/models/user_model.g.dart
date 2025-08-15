// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  email: json['email'] as String,
  fullName: json['fullName'] as String,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  status: json['status'] as String,
  hasCompletedProfile: json['hasCompletedProfile'] as bool,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'fullName': instance.fullName,
  'roles': instance.roles,
  'status': instance.status,
  'hasCompletedProfile': instance.hasCompletedProfile,
};
