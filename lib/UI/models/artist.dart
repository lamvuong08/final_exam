class Artist {
  final int id;
  final String name;
  final String? profileImage;

  Artist({required this.id, required this.name, this.profileImage});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int? ?? -1,
      name: json['name'] ?? 'Nghệ sĩ ẩn danh',
      profileImage: json['profileImage'] as String?,
    );
  }

  factory Artist.fromJsonDetail(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int? ?? -1,
      name: json['name'] ?? 'Nghệ sĩ ẩn danh',
      profileImage: json['profileImage'] as String?,
    );
  }
}