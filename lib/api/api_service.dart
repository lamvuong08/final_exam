import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../UI/models/user.dart';

class ApiService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  /* ===================== PROFILE ===================== */

  Future<UserModel> fetchProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/profile/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load profile');
    }

    return UserModel.fromJson(jsonDecode(response.body));
  }

  Future<bool> updateProfile({
    required int id,
    required String username,
  }) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/profile/update'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'id': id,
        'username': username,
      }),
    );

    return response.statusCode == 200;
  }

  Future<bool> changePassword({
    required int id,
    required String oldPw,
    required String newPw,
  }) async {
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/api/profile/change-password'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
        'oldPw': oldPw,
        'newPw': newPw,
      }),
    );

    print('status = ${response.statusCode}');
    print('body = ${response.body}');

    return response.statusCode == 200 && response.body == 'true';
  }
  /* ===================== LIBRARY ===================== */

  Future<Map<String, dynamic>> fetchLibrary(int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/library/$userId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load library');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<bool> updateProfileWithImage({
    required int id,
    required String username,
    required File imageFile,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://10.0.2.2:8080/api/profile/update-with-image'),
    );

    request.fields['id'] = id.toString();
    request.fields['username'] = username;

    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: http.MediaType('image', 'jpeg'),
      ),
    );

    final response = await request.send();
    return response.statusCode == 200;
  }
}