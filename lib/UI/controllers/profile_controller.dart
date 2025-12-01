class UserModel {
  String fullName;
  String email;
  String avatarUrl;

  UserModel({
    required this.fullName,
    required this.email,
    required this.avatarUrl,
  });
}

class ProfileController {
  UserModel user = UserModel(
    fullName: "Phương Uyên",
    email: "uyen@example.com",
    avatarUrl:
    "https://cdn-icons-png.flaticon.com/512/3177/3177440.png", // avatar mặc định
  );

  /// Cập nhật tên
  Future<void> updateProfile({required String fullName}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    user.fullName = fullName;
  }

  /// Đổi mật khẩu (FAKE)
  Future<bool> changePassword(String oldPass, String newPass) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return newPass.length >= 6; // Quy tắc đơn giản
  }

  void logout() {
    // Em tự làm thêm nếu cần xoá token
  }
}