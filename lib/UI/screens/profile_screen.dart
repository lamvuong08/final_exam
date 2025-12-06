import 'package:flutter/material.dart';
import 'package:music/UI/activity_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import '../models/user.dart' show UserModel;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');

    if (userId == null) {
      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
      return;
    }

    try {
      final api = ApiService();
      final profile = await api.fetchProfile(userId);

      await prefs.setString('user_email', profile.email);
      await prefs.setString('user_username', profile.username);
      await prefs.setString('user_profile_image', profile.profileImage);

      if (!context.mounted) return;
      setState(() {
        user = profile;
        loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi tải profile: $e')),
      );
      setState(() {
        loading = false;
      });
    }
  }

  // ĐỔI TÊN
  Future<void> changeName() async {
    final ctrl = TextEditingController(text: user!.username);
    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Đổi tên", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Tên mới",
            labelStyle: TextStyle(color: Colors.white70),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.red))),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("Lưu", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (newName == null || newName.isEmpty || newName == user!.username) return;

    final api = ApiService();
    bool success = await api.updateProfile(
      id: user!.id,
      username: newName,
      profileImage: user!.profileImage,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Đổi tên thành công!" : "Lỗi khi đổi tên")),
    );

    if (success) {
      loadProfile();
    }
  }
  // ĐỔI AVATAR
  Future<void> changeAvatar() async {
    final ctrl = TextEditingController(text: user!.profileImage);
    final newUrl = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Đổi avatar", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Link ảnh (URL)",
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hủy", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text("Lưu", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (newUrl == null || newUrl.isEmpty || newUrl == user!.profileImage) return;

    final api = ApiService();
    bool success = await api.updateProfile(
      id: user!.id,
      username: user!.username,
      profileImage: newUrl,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Đổi avatar thành công!" : "Lỗi khi đổi avatar")),
    );

    if (success) {
      loadProfile();
    }
  }
  // ĐỔI MẬT KHẨU
  Future<void> changePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Đổi mật khẩu", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Mật khẩu cũ", labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: newCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Mật khẩu mới", labelStyle: TextStyle(color: Colors.white70)),
            ),
            TextField(
              controller: confirmCtrl,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới", labelStyle: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy", style: TextStyle(color: Colors.red))),
          TextButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mật khẩu mới không khớp!"), backgroundColor: Colors.red),
                );
                return;
              }
              Navigator.pop(context, true);
            },
            child: const Text("Xác nhận", style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (result != true) return;

    final api = ApiService();
    final success = await api.changePassword(
      id: user!.id,
      oldPw: oldCtrl.text,
      newPw: newCtrl.text,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? "Đổi mật khẩu thành công!" : "Sai mật khẩu cũ!"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Column(
              children: [
                // Avatar vuông + viền trắng
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        user!.profileImage.isEmpty
                            ? "https://cdn-icons-png.flaticon.com/512/3177/3177440.png"
                            : user!.profileImage,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Username
                Text(
                  user!.username,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black, offset: Offset(1, 1))],
                  ),
                ),
                const SizedBox(height: 6),

                // Email
                Text(
                  user!.email,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),

                // 2 ô Songs + Playlists
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoBox("0", "Songs"),
                    const SizedBox(width: 30),
                    _buildInfoBox("0", "Playlists"),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SizedBox(height: 20),

                Card(
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit, color: Colors.white),
                        title: const Text("Đổi tên", style: TextStyle(color: Colors.white)),
                        onTap: changeName,
                      ),
                      ListTile(
                        leading: const Icon(Icons.image, color: Colors.white),
                        title: const Text("Đổi avatar", style: TextStyle(color: Colors.white)),
                        onTap: changeAvatar,
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock, color: Colors.white),
                        title: const Text("Đổi mật khẩu", style: TextStyle(color: Colors.white)),
                        onTap: changePassword,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  color: Colors.grey[900],
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                    onTap: logout,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String number, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}