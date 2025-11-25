import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = 'http://10.0.2.2:8080/api/auth';

  // 10.0.2.2 là localhost của máy chạy emulator Android
  // Nếu dùng thiết bị thật, dùng IP máy tính trong mạng LAN

  /// Đăng ký người dùng
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Đăng ký thất bại: ${response.body}');
    }
  }

  /// Đăng nhập người dùng
  Future<Map<String, dynamic>> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': usernameOrEmail,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      // Đăng nhập thành công
      return {
        'success': true,
        'user': data,
      };
    } else {
      // Đăng nhập thất bại → trả về thông báo lỗi rõ ràng
      return {
        'success': false,
        'message': data['message'] ?? 'Tài khoản hoặc mật khẩu không đúng',
      };
    }
  }
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    final url = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Lỗi server: ${response.statusCode}'
      };
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String email,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/change-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'newPassword': newPassword,
      }),
    );

    // Phân tích response dù thành công hay thất bại
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
