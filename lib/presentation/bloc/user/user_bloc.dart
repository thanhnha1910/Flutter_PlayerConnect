import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/booking_history_model.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends UserEvent {}

class UpdateUserProfile extends UserEvent {
  final Map<String, dynamic> updates;

  const UpdateUserProfile(this.updates);

  @override
  List<Object?> get props => [updates];
}

class LoadUserBookings extends UserEvent {}

class ChangePassword extends UserEvent {
  final String currentPassword;
  final String newPassword;

  const ChangePassword({
    required this.currentPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserProfileLoaded extends UserState {
  final UserModel user;

  const UserProfileLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class UserBookingsLoaded extends UserState {
  final List<BookingHistoryModel> bookings;

  const UserBookingsLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class UserProfileUpdated extends UserState {
  final UserModel user;

  const UserProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordChanged extends UserState {}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
@lazySingleton
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;

  UserBloc(this.userRepository) : super(UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<LoadUserBookings>(_onLoadUserBookings);
    on<ChangePassword>(_onChangePassword);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final user = await userRepository.getUserProfile();
      emit(UserProfileLoaded(user));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final updatedUser = await userRepository.updateUserProfile(event.updates);
      emit(UserProfileUpdated(updatedUser));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onLoadUserBookings(
    LoadUserBookings event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      final bookings = await userRepository.getUserBookings();
      emit(UserBookingsLoaded(bookings));
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<UserState> emit,
  ) async {
    emit(UserLoading());
    try {
      await userRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(PasswordChanged());
    } catch (e) {
      emit(UserError(e.toString()));
    }
  }
}