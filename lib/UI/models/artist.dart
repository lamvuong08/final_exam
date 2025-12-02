class ArtistModel {
  final int id;
  final String name;
  final String avatarUrl;

  ArtistModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'],
      name: json['name'],
      avatarUrl: json['avatarUrl'],
    );
  }
}