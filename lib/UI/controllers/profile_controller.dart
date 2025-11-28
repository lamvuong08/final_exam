import '../models/user.dart';

class ProfileController {
  late UserModel _currentUser;

  final String defaultAvatar =
      "https://upload.wikimedia.org/wikipedia/commons/9/99/Sample_User_Icon.png";

  ProfileController() {
    _currentUser = UserModel(
      id: 1,
      username: "phuonguyen",
      fullName: "Phương Uyên",
      email: "uyen@example.com",
      avatarUrl: defaultAvatar,
      plan: "Premium",
      followers: 123,
      following: 45,
    );
  }

  // GETTERS
  UserModel get user => _currentUser;

  // UPDATE USER — tạo object mới thay vì sửa trực tiếp
  void updateProfile({
    String? fullName,
    String? avatarUrl,
    String? plan,
  }) {
    _currentUser = UserModel(
      id: _currentUser.id,
      username: _currentUser.username,
      fullName: fullName ?? _currentUser.fullName,
      email: _currentUser.email,
      avatarUrl: avatarUrl ?? _currentUser.avatarUrl,
      plan: plan ?? _currentUser.plan,
      followers: _currentUser.followers,
      following: _currentUser.following,
    );
  }

  // FOLLOW
  void follow() {
    _currentUser = UserModel(
      id: _currentUser.id,
      username: _currentUser.username,
      fullName: _currentUser.fullName,
      email: _currentUser.email,
      avatarUrl: _currentUser.avatarUrl,
      plan: _currentUser.plan,
      followers: _currentUser.followers + 1,
      following: _currentUser.following,
    );
  }

  // UNFOLLOW
  void unfollow() {
    if (_currentUser.followers > 0) {
      _currentUser = UserModel(
        id: _currentUser.id,
        username: _currentUser.username,
        fullName: _currentUser.fullName,
        email: _currentUser.email,
        avatarUrl: _currentUser.avatarUrl,
        plan: _currentUser.plan,
        followers: _currentUser.followers - 1,
        following: _currentUser.following,
      );
    }
  }
  void logout() {
    print("User logged out");
  }
}
