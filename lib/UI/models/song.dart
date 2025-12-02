class SongModel {
  final int id;
  final String title;
  final String artist;
  final String thumbnail;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.thumbnail,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      thumbnail: json['thumbnail'],
    );
  }
}