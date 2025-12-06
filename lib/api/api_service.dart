import 'dart:convert';
import 'package:http/http.dart' as http;

import '../UI/models/user.dart';
import '../UI/models/playlist.dart';
import '../UI/models/artist.dart';
import '../UI/models/song.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // ===================== PROFILE =========================

  Future<UserModel> fetchProfile(int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/profile/$userId'),
    );

    if (res.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(res.body));
    } else {
      throw Exception("Failed to load profile");
    }
  }

  Future<bool> updateProfile({
    required int id,
    required String username,
    String? profileImage,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile/update'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "id": id,
        "username": username,
        "profileImage": profileImage ?? "",
      }),
    );

    return res.statusCode == 200;
  }

  Future<bool> changePassword({
    required int id,
    required String oldPw,
    required String newPw,
  }) async {
    final res = await http.put(
      Uri.parse(
          '$baseUrl/profile/change-password?id=$id&oldPw=$oldPw&newPw=$newPw'),
    );

    return res.statusCode == 200;
  }

  // ===================== LIBRARY =========================

  Future<Map<String, dynamic>> fetchLibrary(int userId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/library/$userId"),
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception("Failed to load library");
    }
  }
}