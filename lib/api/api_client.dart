import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String _baseUrl = 'http://10.0.2.2:8080/api/auth';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    return _post(
      endpoint: '/send-otp',
      body: {'email': email},
      defaultError: 'Lỗi không xác định',
    );
  }

  static Future<Map<String, dynamic>> verifyOtp(
      String email,
      String otp,
      ) async {
    return _post(
      endpoint: '/verify-otp',
      body: {'email': email, 'otp': otp},
      defaultError: 'OTP không hợp lệ.',
    );
  }

  static Future<Map<String, dynamic>> _post({
    required String endpoint,
    required Map<String, dynamic> body,
    required String defaultError,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: _jsonHeaders,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
        };
      }

      return {
        'success': false,
        'message': data['message'] ?? defaultError,
      };
    } catch (_) {
      return {
        'success': false,
        'message': 'Không thể kết nối server.',
      };
    }
  }
}