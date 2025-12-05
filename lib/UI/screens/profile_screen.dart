import 'package:flutter/material.dart';
import 'package:music/UI/activity_login.dart';
import '../../api/api_service.dart';
import '../models/user.dart' show UserModel;
import 'package:music/UI/activity_login.dart'; // CHỈNH đường dẫn đến màn login của bạn

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

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    final api = ApiService();
    final profile = await api.fetchProfile(1); // userId test

    setState(() {
      user = profile;
      loading = false;
    });
  }

  // ================= ĐỔI TÊN =================
  Future<void> changeName() async {
    final ctrl = TextEditingController(text: user!.username);

    final newName = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đổi tên"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Tên mới"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text("Lưu")),
        ],
      ),
    );

    if (newName == null || newName.isEmpty) return;

    final api = ApiService();
    await api.updateProfile(
      id: user!.id,
      fullName: newName,
      profileImage: user!.profileImage,
    );

    await loadProfile();
  }

  // ================= ĐỔI AVATAR =================
  Future<void> changeAvatar() async {
    final ctrl = TextEditingController(text: user!.profileImage);

    final newUrl = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đổi Avatar"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Link hình"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, ctrl.text), child: const Text("Lưu")),
        ],
      ),
    );

    if (newUrl == null || newUrl.isEmpty) return;

    final api = ApiService();
    await api.updateProfile(
      id: user!.id,
      fullName: user!.username,
      profileImage: newUrl,
    );

    await loadProfile();
  }

  // ================= ĐỔI MẬT KHẨU =================
  Future<void> changePassword() async {
    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Đổi mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu cũ")),
            TextField(controller: newCtrl, obscureText: true, decoration: const InputDecoration(labelText: "Mật khẩu mới")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xác nhận")),
        ],
      ),
    );

    if (confirm != true) return;

    final api = ApiService();
    final ok = await api.changePassword(
      id: user!.id,
      oldPw: oldCtrl.text,
      newPw: newCtrl.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? "Đổi mật khẩu thành công" : "Sai mật khẩu cũ"),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  // ================= LOGOUT =================
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
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: changeAvatar,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user!.profileImage.isEmpty
                          ? "https://cdn-icons-png.flaticon.com/512/3177/3177440.png"
                          : user!.profileImage,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user!.username, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                Text(user!.email, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Card(
            color: Colors.grey[900],
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text("Đổi tên", style: TextStyle(color: Colors.white)),
                  onTap: () async {
                    await changeName();
                    await loadProfile();
                  }
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
    );
  }
}