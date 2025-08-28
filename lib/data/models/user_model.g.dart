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
  phoneNumber: json['phoneNumber'] as String?,
  address: json['address'] as String?,
  profilePicture: json['profilePicture'] as String?,
  isDiscoverable: json['isDiscoverable'] as bool?,
  bookingCount: (json['bookingCount'] as num?)?.toInt(),
  memberLevel: (json['memberLevel'] as num?)?.toInt(),
  sportProfiles: json['sportProfiles'] as Map<String, dynamic>?,
  roles: (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
  status: json['status'] as String,
  hasCompletedProfile: json['hasCompletedProfile'] as bool,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'fullName': instance.fullName,
  'phoneNumber': instance.phoneNumber,
  'address': instance.address,
  'profilePicture': instance.profilePicture,
  'isDiscoverable': instance.isDiscoverable,
  'bookingCount': instance.bookingCount,
  'memberLevel': instance.memberLevel,
  'sportProfiles': instance.sportProfiles,
  'roles': instance.roles,
  'status': instance.status,
  'hasCompletedProfile': instance.hasCompletedProfile,
};
