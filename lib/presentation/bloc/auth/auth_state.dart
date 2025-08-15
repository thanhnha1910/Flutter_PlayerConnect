import 'package:equatable/equatable.dart';
import 'package:player_connect/data/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  
  const Authenticated({required this.user});
  
  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class AuthSuccessMessage extends AuthState {
  final String message;
  
  const AuthSuccessMessage({required this.message});
  
  @override
  List<Object> get props => [message];
}