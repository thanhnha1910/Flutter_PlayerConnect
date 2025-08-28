import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel extends Equatable {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final String? profilePicture;
  final bool? isDiscoverable;
  final int? bookingCount;
  final int? memberLevel;
  final Map<String, dynamic>? sportProfiles;
  final List<String> roles;
  final String status;
  final bool hasCompletedProfile;
  
  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.profilePicture,
    this.isDiscoverable,
    this.bookingCount,
    this.memberLevel,
    this.sportProfiles,
    required this.roles,
    required this.status,
    required this.hasCompletedProfile,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle roles parsing - convert from object array to string array
    List<String> parsedRoles = [];
    if (json['roles'] != null) {
      final rolesData = json['roles'] as List<dynamic>;
      parsedRoles = rolesData.map((role) {
        if (role is String) {
          return role;
        } else if (role is Map<String, dynamic> && role['name'] != null) {
          return role['name'] as String;
        }
        return 'ROLE_USER'; // fallback
      }).toList();
    }
    
    // Create a modified json map with parsed roles
    final modifiedJson = Map<String, dynamic>.from(json);
    modifiedJson['roles'] = parsedRoles;
    
    return _$UserModelFromJson(modifiedJson);
  }
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  @override
  List<Object?> get props => [
    id, username, email, fullName, phoneNumber, address, profilePicture,
    isDiscoverable, bookingCount, memberLevel, sportProfiles, roles, status, hasCompletedProfile
  ];
}
