import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'jwt_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class JwtResponseModel extends Equatable {
  final String token;
  final String refreshToken;
  final String type;
  final int id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final String status;
  final bool hasCompletedProfile;
  
  const JwtResponseModel({
    required this.token,
    required this.refreshToken,
    required this.type,
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.status,
    required this.hasCompletedProfile,
  });
  
  factory JwtResponseModel.fromJson(Map<String, dynamic> json) => _$JwtResponseModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$JwtResponseModelToJson(this);
  
  // Convert to UserModel for domain layer
  UserModel toUser() {
    return UserModel(
      id: id,
      username: username,
      email: email,
      fullName: fullName,
      roles: roles,
      status: status,
      hasCompletedProfile: hasCompletedProfile,
    );
  }
  
  @override
  List<Object?> get props => [token, refreshToken, type, id, username, email, fullName, roles, status, hasCompletedProfile];
}
