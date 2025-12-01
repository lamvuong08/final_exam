import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../models/artist.dart';
import '../models/playlist.dart';

class LibraryController extends ChangeNotifier {
  final ApiService api = ApiService();

  List<ArtistModel> artists = [];
  List<PlaylistModel> playlists = [];
  List<PlaylistModel> recentSongs = [];
  List<PlaylistModel> likedSongs = [];

  String defaultAvatar =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png";

  String defaultMusicImage =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Iconic_image_of_music_note.png/240px-Iconic_image_of_music_note.png";

  bool loading = false;

  // ========================= LOAD DATA FROM API =========================
  Future<void> loadLibrary(int userId) async {
    loading = true;
    notifyListeners();

    try {
      final data = await api.fetchLibrary(userId);

      recentSongs = List<PlaylistModel>.from(data['recent']);
      playlists = List<PlaylistModel>.from(data['playlists']);
      likedSongs = List<PlaylistModel>.from(data['liked']);

    } catch (e) {
      print("Load library error: $e");
    }

    loading = false;
    notifyListeners();
  }

  // ========================= ADD ARTIST =========================
  void addArtist(ArtistModel artist) {
    artists.add(artist);
    notifyListeners();
  }

  // ========================= ADD PLAYLIST =========================
  void addPlaylist(PlaylistModel playlist) {
    playlists.add(playlist);
    notifyListeners();
  }

  List<ArtistModel> get artistList => List.unmodifiable(artists);
  List<PlaylistModel> get playlistList => List.unmodifiable(playlists);
}