// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_request_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  email: json['email'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{'email': instance.email, 'password': instance.password};

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      address: json['address'] as String?,
      role: (json['role'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'fullName': instance.fullName,
      'phoneNumber': instance.phoneNumber,
      'address': instance.address,
      'role': instance.role,
    };

ForgotPasswordRequest _$ForgotPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ForgotPasswordRequest(email: json['email'] as String);

Map<String, dynamic> _$ForgotPasswordRequestToJson(
  ForgotPasswordRequest instance,
) => <String, dynamic>{'email': instance.email};
