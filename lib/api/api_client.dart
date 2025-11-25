import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // ⚠️ THAY ĐỔI ĐỊA CHỈ NÀY CHO PHÙ HỢP
  // Android emulator: http://10.0.2.2:8080
  // iOS simulator: http://localhost:8080
  // Thiết bị thật: http://<IP_LOCAL>:8080 (vd: http://192.168.1.10:8080)
  static const String baseUrl = 'http://10.0.2.2:8080/api/auth';

  static Future<Map<String, dynamic>> sendOtp(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      } else {
        return {'success': false, 'message': body['message'] ?? 'Lỗi không xác định'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server.'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'otp': otp}),
    );

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 && body['success'] == true) {
        return {'success': true, 'message': body['message']};
      } else {
        return {'success': false, 'message': body['message'] ?? 'OTP không hợp lệ.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Không thể kết nối server.'};
    }
  }
}