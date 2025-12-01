import 'package:flutter/material.dart';

import 'activity_login.dart';
import 'activity_register.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea( // 👈 (Tùy chọn) Tránh notch/status bar
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // padding trái/phải
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end, // 👈 CHÍNH: đẩy xuống dưới
            crossAxisAlignment: CrossAxisAlignment.center, // 👈 căn giữa ngang
            children: [
              // Logo
              Image.network(
                  "https://www.1min30.com/wp-content/uploads/2018/11/SoundCloud-embleme.jpg"
              ),

              const SizedBox(height: 24),

              // Tiêu đề
              const Text(
                "Chào mừng đến với My Music",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // Tiếp tục bằng email
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    );
                  },
                  label: const Text(
                    "Đăng ký miễn phí",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1DB954), // spotify_green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tiếp tục bằng số điện thoại
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  label: const Text(
                    "Đăng nhập",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white, width: 1.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const SizedBox(height: 32), // Khoảng cách từ nội dung đến đáy
            ],
          ),
        ),
      ),
    );
  }
}