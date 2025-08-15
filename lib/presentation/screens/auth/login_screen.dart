import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/social_login_button.dart';
import '../../widgets/loading_overlay.dart';

// Custom painter for sport field background
class SportFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      80,
      paint,
    );

    // Center dot
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      4,
      dotPaint,
    );

    // Floating geometric shapes
    final shapePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Circles
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.2), 40, shapePaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 30, shapePaint);

    // Rectangles
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.05, size.height * 0.7, 50, 50),
        Radius.circular(10),
      ),
      shapePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.85, size.height * 0.1, 40, 40),
        Radius.circular(8),
      ),
      shapePaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    print('=== UI: Login button pressed ===');
    print('UI: Email: ${_emailController.text.trim()}');
    print('UI: Password length: ${_passwordController.text.length}');
    print('UI: Form validation starting...');
    
    if (_formKey.currentState!.validate()) {
      print('UI: Form validation passed, dispatching LoginRequested event');
      context.read<AuthBloc>().add(
        LoginRequested(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
      print('UI: LoginRequested event dispatched successfully');
    } else {
      print('UI: Form validation failed');
    }
  }

  void _googleSignIn() {
    context.read<AuthBloc>().add(GoogleSignInRequested());
  }

  Widget _buildEnhancedGlassTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.9),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.black.withValues(alpha: 0.8),
            fontSize: 14,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: Icon(
              prefixIcon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20,
            ),
          ),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppTheme.primaryAccent.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppTheme.errorColor.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(
              color: AppTheme.errorColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          errorStyle: TextStyle(
            color: AppTheme.errorColor.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is Authenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: Stack(
              children: [
                // Background with Sports Theme
                 Positioned.fill(
                   child: Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         begin: Alignment.topLeft,
                         end: Alignment.bottomRight,
                         colors: [
                           Color(0xFF1e3c72),
                           Color(0xFF2a5298),
                           Color(0xFF1e3c72),
                         ],
                         stops: [0.0, 0.5, 1.0],
                       ),
                     ),
                     child: CustomPaint(
                       painter: SportFieldPainter(),
                       size: Size.infinite,
                     ),
                   ),
                 ),
                
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withValues(alpha: 0.6),
                          Colors.black.withValues(alpha: 0.3)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                
                // Main Content
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 60),
                          
                          // App Logo and Title
                          Column(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryAccent,
                      AppTheme.primaryAccent.withValues(alpha: 0.7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primaryAccent.withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/images/logo.png',
  width: 60,
  height: 60,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'PlayerConnect',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(0, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Kết nối đam mê thể thao',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Enhanced Glassmorphism Card
                          ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(28),
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.2),
                                      Colors.white.withValues(alpha: 0.1),
                                      Colors.white.withValues(alpha: 0.05),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                      spreadRadius: 0,
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      blurRadius: 10,
                                      offset: const Offset(-5, -5),
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    children: [
                                      // Enhanced Email Field
                                      Container(
                                        key: const Key('email_field'),
                                        child: _buildEnhancedGlassTextField(
                                          controller: _emailController,
                                          label: 'Email',
                                          hintText: 'Nhập email của bạn',
                                          prefixIcon: Icons.email_outlined,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Vui lòng nhập email';
                                            }
                                            if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                .hasMatch(value)) {
                                              return 'Email không hợp lệ';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Enhanced Password Field
                                      Container(
                                        key: const Key('password_field'),
                                        child: _buildEnhancedGlassTextField(
                                          controller: _passwordController,
                                          label: 'Mật khẩu',
                                          hintText: 'Nhập mật khẩu của bạn',
                                          prefixIcon: Icons.lock_outline,
                                          obscureText: _obscurePassword,
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons.visibility_off_outlined,
                                              color: Colors.white.withValues(alpha: 0.7),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Vui lòng nhập mật khẩu';
                                            }
                                            if (value.length < 6) {
                                              return 'Mật khẩu phải có ít nhất 6 ký tự';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // Forgot Password
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pushNamed('/forgot-password');
                                          },
                                          child: Text(
                                            'Quên mật khẩu?',
                                            style: TextStyle(
                                              color: AppTheme.primaryAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Login Button
                                      CustomButton(
                                        key: const Key('login_button'),
                                        text: 'Đăng nhập',
                                        onPressed: _login,
                                        isLoading: state is AuthLoading,
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Divider
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            child: Text(
                                              'Hoặc',
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Divider(
                                              color: Colors.white.withValues(alpha: 0.3),
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Google Sign In
                                      SocialLoginButton(
                                        text: 'Đăng nhập với Google',
                                        iconPath: 'assets/icons/google.png',
                                        onPressed: _googleSignIn,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Sign Up Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Chưa có tài khoản? ',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 16,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/register');
                                },
                                child: Text(
                                  'Đăng ký ngay',
                                  style: TextStyle(
                                    color: AppTheme.primaryAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}