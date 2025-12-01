class PlaylistModel {
  final int id;
  final String name;
  final int songCount;
  final String image;

  PlaylistModel({
    this.id = 0,
    this.name = '',
    this.songCount = 0,
    this.image = '',
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      songCount: json['songCount'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  factory PlaylistModel.fromString(String name) {
    return PlaylistModel(
      id: 0,
      name: name,
      songCount: 0,
      image: '',
    );
  }
}