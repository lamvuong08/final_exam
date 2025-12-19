import 'package:flutter/material.dart';
import '../api/auth_service.dart';

import 'activity_login.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Back button + Title
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 24,
                    padding: EdgeInsets.zero,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Đăng ký',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _usernameController,
                          hintText: 'Tên người dùng',
                          keyboardType: TextInputType.text,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          controller: _passwordController,
                          hintText: 'Mật khẩu',
                          obscureText: _obscurePassword,
                          onToggle: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        const SizedBox(height: 16),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hintText: 'Xác nhận mật khẩu',
                          obscureText: _obscureConfirmPassword,
                          onToggle: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              onChanged: (value) {
                                setState(() {
                                  _acceptedTerms = value ?? false;
                                });
                              },
                              activeColor: const Color(0xFF1DB954),
                              checkColor: Colors.black,
                            ),
                            Expanded(
                              child: Text(
                                'Tôi đồng ý với các điều khoản và điều kiện',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true && _acceptedTerms) {
                      final authService = AuthService();

                      try {
                        final response = await authService.register(
                          username: _usernameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text.trim(),
                        );
                        if (!context.mounted) return;

                        if (response['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đăng ký thành công!')),
                          );
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đăng ký thất bại: ${response['message'] ?? ''}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi: $e')),
                        );
                      }
                    } else if (!_acceptedTerms) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng đồng ý điều khoản')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1DB954),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'Đăng ký',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen()),
                    );
                },
                child: const Text(
                  'Đã có tài khoản? Đăng nhập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $hintText';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
        suffixIcon: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Vui lòng nhập $hintText';
        }
        if (hintText.contains('Mật khẩu') && value.length < 6) {
          return 'Mật khẩu phải có ít nhất 6 ký tự';
        }
        if (hintText == 'Xác nhận mật khẩu' &&
            value != _passwordController.text) {
          return 'Mật khẩu không khớp';
        }
        return null;
      },
    );
  }
}