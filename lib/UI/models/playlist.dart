class PlaylistModel {
  final int id;
  final String name;

  PlaylistModel({
    required this.id,
    required this.name,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      id: json['id'],
      name: json['name'],
    );
  }
}