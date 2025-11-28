class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String avatarUrl;
  final String plan;
  final int followers;
  final int following;

  UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.avatarUrl,
    required this.plan,
    required this.followers,
    required this.following,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      plan: json['plan'] ?? '',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}
