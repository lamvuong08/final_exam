import 'dart:convert';
import 'package:http/http.dart' as http;
import '../UI/models/song.dart';

class SongService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<List<Song>> fetchSongsByArtist(int artistId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/songs/artist/$artistId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((songJson) => Song.fromJson(songJson)).toList();
    } else {
      throw Exception('Failed to load songs: ${response.statusCode}');
    }
  }

  static Future<void> likeSong(int songId, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/user/$userId/song/$songId/like'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Like song failed: ${response.statusCode}');
    }
  }

  static Future<void> unlikeSong(int songId, int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/user/$userId/song/$songId/like'),
    );

    if (response.statusCode != 200) {
      throw Exception('Unlike song failed: ${response.statusCode}');
    }
  }

  static Future<bool> isSongLiked(int songId, int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/$userId/song/$songId/like/check'),
    );

    if (response.statusCode == 200) {
      final bodyStr = response.body.trim().toLowerCase();
      return bodyStr == 'true';
    } else {
      return false;
    }
  }
}
