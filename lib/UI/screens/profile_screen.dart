import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = ProfileController();

  @override
  Widget build(BuildContext context) {
    final user = controller.user;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================== AVATAR + NAME + EMAIL ==================
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user.avatarUrl),
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Divider(color: Colors.white24),

          // ================== ACCOUNT SECTION ==================
          const _ProfileSectionTitle('Tài khoản'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Chỉnh sửa hồ sơ',
                  style: TextStyle(color: Colors.white)),
              subtitle: const Text('Thay đổi tên, avatar, vv.',
                  style: TextStyle(color: Colors.white54)),
              onTap: () {
                // Future: Navigate to Edit Profile screen
                setState(() {
                  controller.updateProfile(fullName: "Tên mới test");
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock, color: Colors.white),
              title: const Text('Thay đổi password',
                  style: TextStyle(color: Colors.white)),
              onTap: () {},
            ),
          ]),

          const SizedBox(height: 16),

          // ================== SECURITY SECTION ==================
          const _ProfileSectionTitle('Security'),
          _buildCard([
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Log out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                controller.logout();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Logged out")),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  // ================== CARD BUILDER ==================
  Widget _buildCard(List<Widget> children) {
    return Card(
      color: Colors.grey[900],
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(color: Colors.white24, height: 1),
          ]
        ],
      ),
    );
  }
}

// ================== SECTION TITLE HEADER ==================
class _ProfileSectionTitle extends StatelessWidget {
  final String text;
  const _ProfileSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
