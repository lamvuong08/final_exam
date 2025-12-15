import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtistService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static Future<void> followArtist(int artistId, int userId) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/user/$userId/follow/artist/$artistId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Follow artist failed: ${response.statusCode}');
    }
  }

  static Future<void> unfollowArtist(int artistId, int userId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/api/user/$userId/follow/artist/$artistId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Unfollow artist failed: ${response.statusCode}');
    }
  }

  static Future<bool> isArtistFollowed(int artistId, int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/user/$userId/follow/artist/$artistId/check'),
    );

    if (response.statusCode == 200) {
      final bodyStr = response.body.trim().toLowerCase();
      return bodyStr == 'true';
    } else {
      return false;
    }
  }

}