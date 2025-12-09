import 'dart:convert';
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
}