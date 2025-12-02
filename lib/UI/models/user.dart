class UserModel {
  final int id;
  final String username;
  final String email;
  final String profileImage;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      profileImage: json['profileImage'] ?? "",
    );
  }
}