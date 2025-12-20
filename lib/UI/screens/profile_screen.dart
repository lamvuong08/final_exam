import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        throw Exception("UserId is null");
      }

      final api = ApiService();
      final profile = await api.fetchProfile(userId);

      if (!mounted) return;

      setState(() {
        user = profile;
      });
    } catch (e) {
      debugPrint("❌ Load profile error: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tải được thông tin người dùng")),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

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

    if (newName == null || newName.isEmpty || newName == user!.username) return;

    final api = ApiService();
    final success = await api.updateProfile(
      id: user!.id,
      username: newName,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Đổi tên thành công!" : "Lỗi khi đổi tên")),
    );

    if (success) {
      loadProfile();
    }
  }

  Future<void> changeAvatar() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return;


    final success = await ApiService().updateProfileWithImage(
      id: user!.id,
      username: user!.username,
      imageFile: File(picked.path),
    );


    if (!mounted) return;

    if (success) {
      await loadProfile();
    }
  }

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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              if (newCtrl.text != confirmCtrl.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Mật khẩu mới không khớp!")),
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

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    backgroundImage: user!.profileImage.isNotEmpty
                        ? NetworkImage(
                      '${user!.profileImage}?t=${DateTime.now().millisecondsSinceEpoch}',
                    )
                        : null,
                    child: user!.profileImage.isEmpty
                        ? const Icon(Icons.person, size: 50, color: Colors.white70)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user!.username,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(user!.email, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
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
      ),
    );
  }
}