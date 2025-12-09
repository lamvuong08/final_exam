import 'package:music/UI/models/song.dart';
import 'artist.dart';

class Album {
  final int id;
  final String title;
  final String? coverImage;
  final int? releaseYear;
  final int songCount;
  final Artist artist;
  final List<Song>? songs;

  Album({
    required this.id,
    required this.title,
    this.coverImage,
    this.releaseYear,
    required this.songCount,
    required this.artist,
    this.songs,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    // Parse artist cơ bản (dành cho danh sách)
    Map<String, dynamic>? artistJson = json['artist'];
    Artist artist;
    if (artistJson != null) {
      artist = Artist(
        id: artistJson['id'] as int,
        name: artistJson['name'] ?? 'Nghệ sĩ ẩn danh',
        profileImage: artistJson['profileImage'] as String?,
      );
    } else {
      artist = Artist(id: -1, name: 'Unknown');
    }

    return Album(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['coverImage'] as String?,
      releaseYear: json['releaseYear'] as int?,
      songCount: json['songCount'] as int,
      artist: artist,
      songs: null,
    );
  }

  factory Album.fromJsonDetail(Map<String, dynamic> json) {
    List<Song>? songs;
    if (json['songs'] != null) {
      songs = (json['songs'] as List)
          .map((s) => Song.fromJsonBrief(s as Map<String, dynamic>))
          .toList();
    }

    // Parse artist thủ công — tránh parse songs trong artist
    Map<String, dynamic>? artistJson = json['artist'];
    Artist artist;
    if (artistJson != null) {
      artist = Artist(
        id: artistJson['id'] as int,
        name: artistJson['name'] ?? 'Nghệ sĩ ẩn danh',
        profileImage: artistJson['profileImage'] as String?,
      );
    } else {
      artist = Artist(id: -1, name: 'Unknown');
    }

    return Album(
      id: json['id'] as int,
      title: json['title'] as String,
      coverImage: json['coverImage'] as String?,
      releaseYear: json['releaseYear'] as int?,
      songCount: songs?.length ?? 0,
      artist: artist,
      songs: songs,
    );
  }
}