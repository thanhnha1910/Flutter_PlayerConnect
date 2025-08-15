import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final String status;
  final bool hasCompletedProfile;
  
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.status,
    required this.hasCompletedProfile,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  @override
  List<Object?> get props => [
    id, username, email, fullName, roles, status, hasCompletedProfile
  ];
}
