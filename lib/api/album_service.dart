import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../UI/models/song.dart';

class AlbumService {
  static Future<List<Song>> fetchSongsByAlbum(int albumId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/albums/$albumId/songs'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((songJson) => Song.fromJson(songJson)).toList();
    } else {
      throw Exception('Failed to load songs: ${response.statusCode}');
    }
  }

  // --- FOLLOW / UNFOLLOW ---
  static Future<void> followAlbum(int albumId, int userId) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/user/$userId/follow/album/$albumId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Follow album failed: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> unfollowAlbum(int albumId, int userId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8080/api/user/$userId/follow/album/$albumId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId}),
    );
    if (response.statusCode != 200) {
      throw Exception('Unfollow album failed: ${response.statusCode} ${response.body}');
    }
  }

  static Future<bool> isAlbumFollowed(int albumId, int userId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/user/$userId/follow/album/$albumId/check'),
    );

    if (response.statusCode == 200) {
      try {
        final bodyStr = response.body.trim().toLowerCase();
        // Nếu server trả true/false hoặc {"following": true}
        final isFollowed = bodyStr == 'true' ||
            (bodyStr.startsWith('{') && jsonDecode(bodyStr)['following'] == true);
        return isFollowed;
      } catch (_) {
        return false;
      }
    } else {
      return false;
    }
  }

}