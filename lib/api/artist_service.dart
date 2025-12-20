import 'package:http/http.dart' as http;

class ArtistService {
  static const String _baseUrl = 'http://10.0.2.2:8080';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  static String _artistFollowUrl(int userId, int artistId) =>
      '$_baseUrl/api/user/$userId/follow/artist/$artistId';

  /* ===================== FOLLOW ===================== */

  static Future<void> followArtist(int artistId, int userId) async {
    final response = await http.post(
      Uri.parse(_artistFollowUrl(userId, artistId)),
      headers: _headers,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Follow artist failed: ${response.statusCode}');
    }
  }

  static Future<void> unfollowArtist(int artistId, int userId) async {
    final response = await http.delete(
      Uri.parse(_artistFollowUrl(userId, artistId)),
      headers: _headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Unfollow artist failed: ${response.statusCode}');
    }
  }

  /* ===================== CHECK FOLLOW ===================== */

  static Future<bool> isArtistFollowed(int artistId, int userId) async {
    final response = await http.get(
      Uri.parse('${_artistFollowUrl(userId, artistId)}/check'),
      headers: _headers,
    );

    if (response.statusCode != 200) return false;

    return response.body.trim().toLowerCase() == 'true';
  }
}