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
    this.id = 0,
    this.username = '',
    this.fullName = '',
    this.email = '',
    this.avatarUrl = '',
    this.plan = 'Free',
    this.followers = 0,
    this.following = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
      plan: json['plan'] ?? 'Free',
      followers: json['followers'] ?? 0,
      following: json['following'] ?? 0,
    );
  }
}