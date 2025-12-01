import 'dart:convert';
import 'package:http/http.dart' as http;

import '../UI/models/user.dart';
import '../UI/models/playlist.dart';
import '../UI/models/artist.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  // ===================== PROFILE =========================

  Future<UserModel> fetchProfile(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/profile/$userId'));

    if (res.statusCode == 200) {
      final data = json.decode(res.body);

      return UserModel.fromJson(data);
    } else {
      throw Exception('Failed to load profile (${res.statusCode})');
    }
  }

  Future<bool> updateProfile({
    required int id,
    String? fullName,
    String? avatarUrl,
  }) async {
    final res = await http.put(
      Uri.parse('$baseUrl/profile/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': id,
        'fullName': fullName ?? '',
        'avatarUrl': avatarUrl ?? '',
      }),
    );

    return res.statusCode == 200;
  }

  Future<Map<String, dynamic>> changePassword({
    required int id,
    required String oldPassword,
    required String newPassword,
  }) async {
    final res = await http.put(
      Uri.parse(
          '$baseUrl/profile/change-password?id=$id&oldPw=$oldPassword&newPw=$newPassword'),
    );

    return {
      'success': res.statusCode == 200,
      'message': res.body
    };
  }

  // ===================== LIBRARY =========================

  Future<Map<String, dynamic>> fetchLibrary(int userId) async {
    final res = await http.get(Uri.parse('$baseUrl/library/$userId'));

    if (res.statusCode != 200) {
      throw Exception('Failed to load library (${res.statusCode})');
    }

    final data = json.decode(res.body);

    return {
      'recent': (data['recentSongs'] as List?)
          ?.map((e) => PlaylistModel.fromString(e['title'] ?? ''))
          .toList() ??
          [],
      'playlists': (data['playlists'] as List?)
          ?.map((e) => PlaylistModel.fromString(e.toString()))
          .toList() ??
          [],
      'liked': (data['likedSongs'] as List?)
          ?.map((e) => PlaylistModel.fromString(e['title'] ?? ''))
          .toList() ??
          [],
    };
  }
}