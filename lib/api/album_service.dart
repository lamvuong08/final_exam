import 'dart:convert';
import 'package:http/http.dart' as http;
import '../UI/models/song.dart';

class AlbumService {
  static const String _baseUrl = 'http://10.0.2.2:8080/api';
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // ===================== SONGS =====================
  static Future<List<Song>> fetchSongsByAlbum(int albumId) async {
    final res = await http.get(Uri.parse('$_baseUrl/albums/$albumId/songs'));

    if (res.statusCode == 200) {
      final List<dynamic> data = jsonDecode(res.body);
      return data.map((json) => Song.fromJson(json)).toList();
    }
    throw Exception('Failed to load songs: ${res.statusCode}');
  }

  // ===================== FOLLOW / UNFOLLOW =====================
  static Future<void> followAlbum(int albumId, int userId) async {
    await _postOrDelete(
      method: 'POST',
      endpoint: '/user/$userId/follow/album/$albumId',
      body: {'userId': userId},
      errorMsg: 'Follow album failed',
    );
  }

  static Future<void> unfollowAlbum(int albumId, int userId) async {
    await _postOrDelete(
      method: 'DELETE',
      endpoint: '/user/$userId/follow/album/$albumId',
      body: {'userId': userId},
      errorMsg: 'Unfollow album failed',
    );
  }

  static Future<bool> isAlbumFollowed(int albumId, int userId) async {
    final res = await http.get(Uri.parse('$_baseUrl/user/$userId/follow/album/$albumId/check'));

    if (res.statusCode == 200) {
      final bodyStr = res.body.trim().toLowerCase();
      try {
        return bodyStr == 'true' ||
            (bodyStr.startsWith('{') && jsonDecode(bodyStr)['following'] == true);
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  // ===================== PRIVATE HELPER =====================
  static Future<void> _postOrDelete({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    required String errorMsg,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    late final http.Response res;

    if (method == 'POST') {
      res = await http.post(uri, headers: _jsonHeaders, body: jsonEncode(body ?? {}));
    } else if (method == 'DELETE') {
      res = await http.delete(uri, headers: _jsonHeaders, body: jsonEncode(body ?? {}));
    } else {
      throw Exception('Unsupported HTTP method: $method');
    }

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('$errorMsg: ${res.statusCode} ${res.body}');
    }
  }
}