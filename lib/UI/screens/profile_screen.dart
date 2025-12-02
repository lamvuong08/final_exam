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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ================= LOAD PROFILE =================
  Future<void> loadProfile() async {
    try {
      final api = ApiService();
      final profile = await api.fetchProfile(2);

      setState(() {
        user = profile;
        loading = false;
      });
    } catch (e) {
      print("Load profile error: $e");
    }
  }

  // ================= UPDATE NAME =================
  Future<void> changeName() async {
    if (user == null) return;

    final TextEditingController nameCtrl =
    TextEditingController(text: user!.username);

    // Mở dialog nhập tên mới
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Đổi tên"),
          content: TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Tên mới"),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
            TextButton(
                onPressed: () =>
                    Navigator.pop(context, nameCtrl.text.trim()),
                child: const Text("Lưu")),
          ],
        );
      },
    );

    if (newName == null || newName.isEmpty) return;

    final api = ApiService();

    bool ok = await api.updateProfile(
      id: user!.id,
      fullName: newName,
    );

    if (ok) {
      await loadProfile();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi tên thành công")),
      );
    }
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
        title: const Text("Profile"),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===================== AVATAR + NAME + EMAIL =====================
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    user!.profileImage.isEmpty
                        ? "https://cdn-icons-png.flaticon.com/512/3177/3177440.png"
                        : user!.profileImage,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user!.username,
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

          // ===================== ACCOUNT CARD =====================
          Card(
            color: Colors.grey[900],
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.edit, color: Colors.white),
                  title: const Text("Chỉnh sửa hồ sơ",
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Thay đổi tên, avatar...",
                      style: TextStyle(color: Colors.white54)),
                  onTap: changeName,
                ),
                const Divider(color: Colors.white24),
                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.white),
                  title: const Text("Thay đổi mật khẩu",
                      style: TextStyle(color: Colors.white)),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Chức năng đổi mật khẩu đang hoàn thiện")),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          const Text("Security",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),

          // ===================== LOG OUT =====================
          Card(
            color: Colors.grey[900],
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Log out", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}