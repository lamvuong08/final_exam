// lib/controllers/library_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Thêm dòng này
import 'package:http/http.dart' as http;
import '../models/album.dart';
import '../models/song.dart';
import '../models/artist.dart';

class LibraryController with ChangeNotifier { // ✅ Thay đổi từ class LibraryController thành class LibraryController with ChangeNotifier
  List<Song> songs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Map<String, dynamic>> playlists = [];

  static const String baseUrl = 'http://10.0.2.2:8080/api';

  final Map<String, String> _noCacheHeaders = {
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
  };

  void addLikedSong(Song song) {
    if (!songs.any((s) => s.id == song.id)) {
      songs.insert(0, song);
      notifyListeners(); // ✅ Gọi notifyListeners để cập nhật giao diện
    }
  }

  void removeLikedSong(int songId) {
    songs.removeWhere((s) => s.id == songId);
    notifyListeners(); // ✅ Gọi notifyListeners để cập nhật giao diện
  }

  Future<void> loadLibrary(int userId) async {
    await Future.wait([
      _loadLikedSongs(userId),
      _loadFollowedArtists(userId),
      _loadFollowedAlbums(userId),
      _loadPlaylists(userId),
    ]);
    notifyListeners(); // ✅ Gọi notifyListeners sau khi load xong
  }

  Future<void> _loadLikedSongs(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/liked-songs'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      songs = data.map((e) => Song.fromJson(e)).toList();
    }
  }

  Future<void> _loadFollowedArtists(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/library/artists'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      artists = data.map((e) => Artist.fromJson(e)).toList();
    } else {
      artists = [];
    }
  }

  Future<void> _loadFollowedAlbums(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/library/albums'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      albums = data.map((e) => Album.fromJson(e)).toList();
    } else {
      albums = [];
    }
  }

  Future<void> _loadPlaylists(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/playlists'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      playlists = List<Map<String, dynamic>>.from(data);
    }
  }

  Future<Album> fetchAlbumDetail(int albumId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/albums/$albumId'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Album.fromJsonDetail(data);
    } else {
      throw Exception('Failed to load album detail: ${response.statusCode}');
    }
  }

  Future<Artist> fetchArtistDetail(int artistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$artistId'),
      headers: _noCacheHeaders,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Artist.fromJsonDetail(data);
    } else {
      throw Exception('Failed to load artist detail: ${response.statusCode}');
    }
  }
}