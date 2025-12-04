import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../models/playlist.dart';
import '../models/artist.dart';
import '../models/song.dart';
class LibraryController {
  final ApiService api = ApiService();

  List<PlaylistModel> playlists = [];
  List<ArtistModel> artists = [];
  List<SongModel> song = [];
  Future<void> loadLibrary(int userId) async {
    try {
      final data = await api.fetchLibrary(userId);

      song = (data['likedSongs'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList();

      playlists = (data['playlists'] as List)
          .map((e) => PlaylistModel.fromJson(e))
          .toList();

      artists = (data['favoriteArtists'] as List)
          .map((e) => ArtistModel.fromJson(e))
          .toList();
    } catch (e) {
      print("Load library error: $e");
    }
  }
}