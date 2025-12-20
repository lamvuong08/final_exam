import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  /* ===================== REGISTER ===================== */

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception('Đăng ký thất bại: ${response.body}');
  }

  /* ===================== LOGIN ===================== */

  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({
        'email': usernameOrEmail,
        'password': password,
      }),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return {
        'success': true,
        'user': data,
      };
    }

    return {
      'success': false,
      'message': data['message'] ?? 'Tài khoản hoặc mật khẩu không đúng',
    };
  }

  /* ===================== RESET PASSWORD ===================== */

  Future<Map<String, dynamic>> resetPassword({
    required String email,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      'success': false,
      'message': 'Lỗi server: ${response.statusCode}',
    };
  }

  /* ===================== CHANGE PASSWORD ===================== */

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}