import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../models/user.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.user.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Tên hiển thị",
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.white12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: () async {
                final api = ApiService();

                bool ok = await api.updateProfile(
                  id: widget.user.id,
                  fullName: nameCtrl.text.trim(),
                );

                if (ok && mounted) {
                  Navigator.pop(context, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
              ),
              child: const Text("Lưu", style: TextStyle(fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}