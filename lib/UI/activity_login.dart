import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import 'activity_forgotpassword.dart';
import 'activity_main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double paddingAll = w * 0.05;
    final double fontSizeTitle = w * 0.05;
    final double fontSizeBody = w * 0.04;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(paddingAll),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.arrow_back, color: Colors.white, size: fontSizeTitle),
                      padding: EdgeInsets.zero,
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Đăng nhập',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSizeTitle,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 32),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(color: Colors.white, fontSize: fontSizeBody),
                        decoration: InputDecoration(
                          hintText: 'Email hoặc tên người dùng',
                          hintStyle: TextStyle(color: const Color(0xFFB3B3B3), fontSize: fontSizeBody),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập email hoặc tên người dùng';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: Colors.white, fontSize: fontSizeBody),
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          hintStyle: TextStyle(color: const Color(0xFFB3B3B3), fontSize: fontSizeBody),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white,
                              size: fontSizeBody,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập mật khẩu';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() == true) {
                              final authService = AuthService();
                              try {
                                final response = await authService.login(
                                  usernameOrEmail: _emailController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                                if (!context.mounted) return;

                                if (response['success'] == true) {
                                  final userData = response['user']['user'];
                                  if (userData == null) {
                                    throw Exception('Không tìm thấy dữ liệu người dùng');
                                  }

                                  final prefs = await SharedPreferences.getInstance();
                                  await prefs.setInt('user_id', userData['id']);
                                  await prefs.setString('user_email', userData['email'] ?? '');
                                  await prefs.setString('user_username', userData['username'] ?? 'Ẩn danh');
                                  await prefs.setString('user_profile_image', userData['profileImage'] ?? '');
                                  await prefs.setBool('is_logged_in', true);

                                  if (!context.mounted) return;
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MainScreen(
                                        userId: userData['id'],
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Đăng nhập thất bại: ${response['message'] ?? 'Vui lòng thử lại'}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Lỗi kết nối: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1DB954),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            'Đăng nhập',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainScreen(userId: 0),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Đăng nhập không cần mật khẩu',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const OtpVerificationScreen()),
                            );
                          },
                          child: const Text(
                            'Quên mật khẩu?',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}