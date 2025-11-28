class PlaylistModel {
  final int id;
  final String name;
  final int songCount;
  final String image;

  PlaylistModel({
    required this.id,
    required this.name,
    required this.songCount,
    required this.image,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      songCount: json['songCount'] ?? 0,
      image: json['image'] ?? '',
    );
  }

  // NEW: tạo từ chuỗi tên
  factory PlaylistModel.fromString(String name) {
    return PlaylistModel(
      id: 0,
      name: name,
      songCount: 0,
      image: '',
    );
  }
}
