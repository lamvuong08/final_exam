import 'artist.dart';

class Song {
  final int id;
  final String title;
  final String? coverImage;
  final String? filePath;
  final int? duration;
  final Artist? artist;
  final int? albumId;
  final int? mediaTypeId;
  final String? lyrics;
  final int playCount;

  Song({
    required this.id,
    required this.title,
    this.coverImage,
    this.filePath,
    this.duration,
    this.artist,
    this.albumId,
    this.mediaTypeId,
    this.lyrics,
    required this.playCount,
  });

  factory Song.fromJsonBrief(Map<String, dynamic> json) {
    Map<String, dynamic>? artistJson = json['artist'];
    Artist? artist;
    if (artistJson != null) {
      artist = Artist(
        id: artistJson['id'] as int,
        name: artistJson['name'] ?? 'Nghệ sĩ ẩn danh',
        profileImage: artistJson['profileImage'] as String?,
      );
    }

    return Song(
      id: json['id'] as int,
      title: json['title'] ?? 'Unknown',
      coverImage: json['coverImage'] as String?,
      filePath: json['filePath'] as String?,
      duration: json['duration'] as int?,
      artist: artist,
      albumId: json['albumId'] as int?,
      mediaTypeId: json['mediaTypeId'] as int?,
      lyrics: json['lyrics'] as String?,
      playCount: json['playCount'] as int? ?? 0,
    );
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song.fromJsonBrief(json);
  }
}