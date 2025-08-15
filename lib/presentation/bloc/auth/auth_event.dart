import 'package:equatable/equatable.dart';
import '../../../data/models/auth_request_models.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  
  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  
  const LoginRequested({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final RegisterRequest request;
  
  const RegisterRequested({required this.request});
  
  @override
  List<Object> get props => [request];
}

class GoogleSignInRequested extends AuthEvent {}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  
  const ForgotPasswordRequested({required this.email});
  
  @override
  List<Object> get props => [email];
}

class LogoutRequested extends AuthEvent {}