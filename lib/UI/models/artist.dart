class ArtistModel {
  final int id;
  final String name;
  final String image;

  ArtistModel({
    required this.id,
    required this.name,
    required this.image,
  });

  factory ArtistModel.fromJson(Map<String, dynamic> json) {
    return ArtistModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
    );
  }

  factory ArtistModel.fromString(String name) {
    return ArtistModel(
      id: 0,
      name: name,
      image: '',
    );
  }
}
