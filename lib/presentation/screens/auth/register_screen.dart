import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/auth_request_models.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_overlay.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      final request = RegisterRequest(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isNotEmpty 
            ? _phoneController.text.trim() 
            : null,
      );
      
      context.read<AuthBloc>().add(RegisterRequested(request: request));
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đồng ý với điều khoản sử dụng'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryAccent),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is AuthSuccessMessage) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          return LoadingOverlay(
            isLoading: state is AuthLoading,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        'Tạo tài khoản mới',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Điền thông tin để tạo tài khoản PlayerConnect',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Registration Form Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // Full Name
                              CustomTextField(
                                key: const Key('fullname_field'),
                                controller: _fullNameController,
                                label: 'Họ và tên',
                                hintText: 'Nhập họ và tên đầy đủ',
                                prefixIcon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập họ và tên';
                                  }
                                  if (value.length < 2) {
                                    return 'Họ và tên phải có ít nhất 2 ký tự';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Username
                              CustomTextField(
                                key: const Key('username_field'),
                                controller: _usernameController,
                                label: 'Tên đăng nhập',
                                hintText: 'Nhập tên đăng nhập',
                                prefixIcon: Icons.alternate_email,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tên đăng nhập';
                                  }
                                  if (value.length < 3) {
                                    return 'Tên đăng nhập phải có ít nhất 3 ký tự';
                                  }
                                  if (value.length > 20) {
                                    return 'Tên đăng nhập không được quá 20 ký tự';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Email
                              CustomTextField(
                                key: const Key('email_field'),
                                controller: _emailController,
                                label: 'Email',
                                hintText: 'Nhập địa chỉ email',
                                prefixIcon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập email';
                                  }
                                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                      .hasMatch(value)) {
                                    return 'Email không hợp lệ';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Phone (Optional)
                              CustomTextField(
                                controller: _phoneController,
                                label: 'Số điện thoại (Tùy chọn)',
                                hintText: 'Nhập số điện thoại',
                                prefixIcon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Password
                              CustomTextField(
                                key: const Key('password_field'),
                                controller: _passwordController,
                                label: 'Mật khẩu',
                                hintText: 'Nhập mật khẩu',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
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
                                  if (value.length > 40) {
                                    return 'Mật khẩu không được quá 40 ký tự';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Confirm Password
                              CustomTextField(
                                controller: _confirmPasswordController,
                                label: 'Xác nhận mật khẩu',
                                hintText: 'Nhập lại mật khẩu',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng xác nhận mật khẩu';
                                  }
                                  if (value != _passwordController.text) {
                                    return 'Mật khẩu xác nhận không khớp';
                                  }
                                  return null;
                                },
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Terms and Conditions
                              Row(
                                children: [
                                  Checkbox(
                                    value: _agreeToTerms,
                                    onChanged: (value) {
                                      setState(() {
                                        _agreeToTerms = value ?? false;
                                      });
                                    },
                                    activeColor: AppTheme.primaryAccent,
                                  ),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: Theme.of(context).textTheme.bodySmall,
                                        children: [
                                          const TextSpan(
                                            text: 'Tôi đồng ý với ',
                                          ),
                                          TextSpan(
                                            text: 'Điều khoản sử dụng',
                                            style: TextStyle(
                                              color: AppTheme.primaryAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: ' và ',
                                          ),
                                          TextSpan(
                                            text: 'Chính sách bảo mật',
                                            style: TextStyle(
                                              color: AppTheme.primaryAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Register Button
                              CustomButton(
                                key: const Key('register_button'),
                                text: 'Đăng ký',
                                onPressed: _register,
                                isLoading: state is AuthLoading,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đã có tài khoản? ',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Đăng nhập ngay',
                              style: TextStyle(
                                color: AppTheme.primaryAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}