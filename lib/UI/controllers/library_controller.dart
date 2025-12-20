// lib/controllers/library_controller.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../api/song_service.dart';
import '../models/album.dart';
import '../models/artist.dart';
import '../models/song.dart';

class LibraryController with ChangeNotifier {
  static const String baseUrl = 'http://10.0.2.2:8080/api';

  final Map<String, String> _noCacheHeaders = {
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    'Pragma': 'no-cache',
    'Expires': '0',
    'Content-Type': 'application/json',
  };

  List<Song> likedSongs = [];
  List<Artist> artists = [];
  List<Album> albums = [];
  List<Map<String, dynamic>> playlists = [];

  final List<Song> _playQueue = [];
  List<Song> get playQueue => List.unmodifiable(_playQueue);

  /* ===================== LOAD LIBRARY ===================== */

  Future<void> loadLibrary(int userId) async {
    try {
      await Future.wait([
        _loadLikedSongs(userId),
        _loadFollowedArtists(userId),
        _loadFollowedAlbums(userId),
        _loadPlaylists(userId),
      ]);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ loadLibrary error: $e');
    }
  }

  /* ===================== LIKED SONGS ===================== */

  Future<void> _loadLikedSongs(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/library/liked-songs'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode != 200) {
      likedSongs = [];
      return;
    }

    final List data = jsonDecode(response.body);
    likedSongs = data.map((e) => Song.fromJson(e)).toList();
  }

  Future<void> likeSong(int userId, Song song) async {
    await SongService.likeSong(song.id, userId);

    if (likedSongs.any((s) => s.id == song.id)) return;

    likedSongs.insert(0, song);
    notifyListeners();
  }

  Future<void> unlikeSong(int userId, int songId) async {
    await SongService.unlikeSong(songId, userId);

    likedSongs.removeWhere((s) => s.id == songId);
    notifyListeners();
  }

  /* ===================== ARTISTS ===================== */

  Future<void> _loadFollowedArtists(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/library/artists'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode != 200) {
      artists = [];
      return;
    }

    final List data = jsonDecode(response.body);
    artists = data.map((e) => Artist.fromJson(e)).toList();
  }

  /* ===================== ALBUMS ===================== */

  Future<void> _loadFollowedAlbums(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/library/albums'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode != 200) {
      albums = [];
      return;
    }

    final List data = jsonDecode(response.body);
    albums = data.map((e) => Album.fromJson(e)).toList();
  }

  /* ===================== PLAYLISTS ===================== */

  Future<void> _loadPlaylists(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/$userId/playlists'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode != 200) {
      playlists = [];
      return;
    }

    playlists = List<Map<String, dynamic>>.from(
      jsonDecode(response.body),
    );
  }

  /* ===================== DETAIL FETCH ===================== */

  Future<Album> fetchAlbumDetail(int albumId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/albums/$albumId'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode == 200) {
      return Album.fromJsonDetail(jsonDecode(response.body));
    }

    throw Exception('Failed to load album detail');
  }

  Future<Artist> fetchArtistDetail(int artistId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/artists/$artistId'),
      headers: _noCacheHeaders,
    );

    if (response.statusCode == 200) {
      return Artist.fromJsonDetail(jsonDecode(response.body));
    }

    throw Exception('Failed to load artist detail');
  }

  /* ===================== PLAY QUEUE ===================== */

  void addToQueue(Song song) {
    if (_playQueue.any((s) => s.id == song.id)) return;

    _playQueue.add(song);
    notifyListeners();
  }

  void addAllToQueue(List<Song> songs) {
    for (final song in songs) {
      if (_playQueue.any((s) => s.id == song.id)) continue;
      _playQueue.add(song);
    }
    notifyListeners();
  }

  void clearQueue() {
    _playQueue.clear();
    notifyListeners();
  }
}