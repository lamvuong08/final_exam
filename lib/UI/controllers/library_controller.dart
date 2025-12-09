import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/song.dart';
import '../models/artist.dart';
import '../models/album.dart';

class LibraryController {
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Map<String, dynamic>> playlists = [];

  static const String baseUrl = 'http://10.0.2.2:8080/api';

  Future<void> loadLibrary(int userId) async {
    await Future.wait([
      _loadLikedSongs(userId),
      _loadArtists(),
      _loadAlbums(),
      _loadPlaylists(userId),
    ]);
  }

  Future<void> _loadLikedSongs(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId/liked-songs'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      songs = data.map((e) => Song.fromJson(e)).toList();
    }
  }

  Future<void> _loadArtists() async {
    final response = await http.get(Uri.parse('$baseUrl/artists'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      artists = data.map((e) => Artist.fromJson(e)).toList();
    }
  }

  Future<void> _loadAlbums() async {
    final response = await http.get(Uri.parse('$baseUrl/albums'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      albums = data.map((e) => Album.fromJson(e)).toList();
    }
  }

  Future<void> _loadPlaylists(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/user/$userId/playlists'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      playlists = List<Map<String, dynamic>>.from(data);
    }
  }
  // ─── GỌI API CHI TIẾT ALBUM ───
  Future<Album> fetchAlbumDetail(int albumId) async {
    final response = await http.get(Uri.parse('$baseUrl/albums/$albumId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Album.fromJsonDetail(data); // ⚠️ Dùng fromJsonDetail để tránh vòng lặp
    } else {
      throw Exception('Failed to load album detail: ${response.statusCode}');
    }
  }

  // ─── GỌI API CHI TIẾT ARTIST ───
  Future<Artist> fetchArtistDetail(int artistId) async {
    final response = await http.get(Uri.parse('$baseUrl/artists/$artistId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Artist.fromJsonDetail(data); // ⚠️ Dùng fromJsonDetail
    } else {
      throw Exception('Failed to load artist detail: ${response.statusCode}');
    }
  }
}