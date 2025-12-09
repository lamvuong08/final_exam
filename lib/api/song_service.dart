import 'dart:convert';
import 'package:http/http.dart' as http;
import '../UI/models/song.dart';

class SongService {
  static Future<List<Song>> fetchSongsByArtist(int artistId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/songs/artist/$artistId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((songJson) => Song.fromJson(songJson)).toList();
    } else {
      throw Exception('Failed to load songs: ${response.statusCode}');
    }
  }
}