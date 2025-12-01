import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= LOAD PROFILE FROM API =================
  Future<void> loadProfile() async {
    final api = ApiService();
    final profile = await api.fetchProfile(1); // user ID mặc định

    setState(() {
      user = profile;
    });
  }

  // ================ UPDATE PROFILE =================
  Future<void> changeName() async {
    if (user == null) return;

    final api = ApiService();
    bool ok = await api.updateProfile(
      id: user!.id,
      fullName: "",
    );

    if (ok) {
      await loadProfile();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Đổi tên thành công")));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
      Center(
      child: Column(
      children: [
        CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(user!.avatarUrl),
      ),
      const SizedBox(height: 12),
      Text(
        user!.fullName,
        style: const TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        user!.email,
        style: const TextStyle(color: Colors.white70),
      ),
      ],
    ),
    ),

    const SizedBox(height: 24),

    const Text("Tài khoản",
    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

    Card(
    color: Colors.grey[900],
    child: Column(
    children: [
    ListTile(
    leading: const Icon(Icons.edit, color: Colors.white),
    title: const Text("Chỉnh sửa hồ sơ",
    style: TextStyle(color: Colors.white)),
    subtitle: const Text("Thay đổi tên, avatar ...",
    style: TextStyle(color: Colors.white54)),onTap: changeName,
    ),
      Divider(color: Colors.white24),
      ListTile(
        leading: const Icon(Icons.lock, color: Colors.white),
        title: const Text("Thay đổi mật khẩu",
            style: TextStyle(color: Colors.white)),
        onTap: () {},
      ),
    ],
    ),
    ),

          const SizedBox(height: 16),

          const Text("Security",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title:
              const Text("Log out", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}