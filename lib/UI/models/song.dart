class Artist {
  final int id;
  final String name;

  Artist({required this.id, required this.name});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'],
      name: json['name'] ?? 'Nghệ sĩ ẩn danh',
    );
  }
}
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

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'],
      title: json['title'] ?? 'Unknown',
      coverImage: json['coverImage'],
      filePath: json['filePath'],
      duration: json['duration'],
      artist: json['artist'] != null ? Artist.fromJson(json['artist']) : null,
      albumId: json['albumId'],
      mediaTypeId: json['mediaTypeId'],
      lyrics: json['lyrics'],
      playCount: json['playCount'] ?? 0,
    );
  }
}