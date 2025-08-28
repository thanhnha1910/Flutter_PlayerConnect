import 'package:injectable/injectable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/google_signin_usecase.dart';
import '../../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../auth/auth_event.dart';
import '../auth/auth_state.dart';

@lazySingleton
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final GoogleSignInUseCase googleSignInUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;
  
  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.googleSignInUseCase,
    required this.forgotPasswordUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }
  
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
  
    emit(AuthLoading());
    
    final isLoggedIn = await authRepository.isLoggedIn();
    
    if (isLoggedIn) {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) {
         
          emit(Unauthenticated());
        },
        (user) {
          if (user != null) {
         
            emit(Authenticated(user: user));
          } else {
         
            emit(Unauthenticated());
          }
        },
      );
    } else {
      emit(Unauthenticated());
    }
  }
  
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
   
    
    emit(AuthLoading());
    
    final result = await loginUseCase(event.email, event.password);
    
    result.fold(
      (failure) {
       
        emit(AuthFailure(message: failure.message));
      },
      (user) {
        print('BLoC: Login successful for user: ${user.email}');
        print('BLoC: Emitting Authenticated state');
        emit(Authenticated(user: user));
      },
    );
  }
  
  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await registerUseCase(event.request);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(const AuthSuccessMessage(
        message: 'Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.',
      )),
    );
  }
  
  Future<void> _onGoogleSignInRequested(
    GoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await googleSignInUseCase();
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (user) => emit(Authenticated(user: user)),
    );
  }
  
  Future<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await forgotPasswordUseCase(event.email);
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(const AuthSuccessMessage(
        message: 'Link đặt lại mật khẩu đã được gửi đến email của bạn.',
      )),
    );
  }
  
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    final result = await logoutUseCase();
    result.fold(
      (failure) => emit(AuthFailure(message: failure.message)),
      (_) => emit(Unauthenticated()),
    );
  }
}