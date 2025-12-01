import 'package:flutter/material.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;
  final ProfileController controller;

  const ChangePasswordScreen({
    super.key,
    required this.email,
    required this.controller,
  });

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPw = TextEditingController();
  final newPw = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
        const Text("Thay đổi password", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Email: ${widget.email}",
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),

            _box("Mật khẩu cũ", oldPw),
            const SizedBox(height: 15),
            _box("Mật khẩu mới", newPw),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                bool ok = await widget.controller
                    .changePassword(oldPw.text, newPw.text);

                if (!ok) {
                  setState(() => error = "Mật khẩu mới phải ≥ 6 ký tự");
                  return;
                }

                if (!mounted) return;
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 45),
              ),
              child: const Text("Xác nhận"),
            )
          ],
        ),
      ),
    );
  }

  Widget _box(String title, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}