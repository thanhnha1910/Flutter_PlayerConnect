import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'auth_request_models.g.dart';

@JsonSerializable(explicitToJson: true)
class LoginRequest extends Equatable {
  final String email;
  final String password;
  
  const LoginRequest({
    required this.email,
    required this.password,
  });
  
  factory LoginRequest.fromJson(Map<String, dynamic> json) => 
      _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
  
  @override
  List<Object?> get props => [email, password];
}

@JsonSerializable(explicitToJson: true)
class RegisterRequest extends Equatable {
  final String username;
  final String email;
  final String password;
  final String fullName;
  final String? phoneNumber;
  final String? address;
  final List<String>? role;
  
  const RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.fullName,
    this.phoneNumber,
    this.address,
    this.role,
  });
  
  factory RegisterRequest.fromJson(Map<String, dynamic> json) => 
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
  
  @override
  List<Object?> get props => [
    username, email, password, fullName, phoneNumber, address, role
  ];
}

@JsonSerializable(explicitToJson: true)
class ForgotPasswordRequest extends Equatable {
  final String email;
  
  const ForgotPasswordRequest({required this.email});
  
  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) => 
      _$ForgotPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ForgotPasswordRequestToJson(this);
  
  @override
  List<Object?> get props => [email];
}
