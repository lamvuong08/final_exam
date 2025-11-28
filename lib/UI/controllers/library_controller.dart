import '../models/playlist.dart';
import '../models/artist.dart';


class LibraryController {
  final List<ArtistModel> artists = [];
  final List<PlaylistModel> playlists = [];
  List<ArtistModel> get artist=> List.unmodifiable(artist);
  List<PlaylistModel> get playlist=> List.unmodifiable(playlists);
  String defaultAvatar =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png";
  String defaultMusicImage =
      "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Iconic_image_of_music_note.png/240px-Iconic_image_of_music_note.png";
  void addArtist(ArtistModel artist) {
    artists.add(artist);
  }
  void addPlaylist(PlaylistModel playlist) {
    playlists.add(playlist);
  }
}
