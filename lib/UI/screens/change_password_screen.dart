import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  final int userId;
  final String email;

  const ChangePasswordScreen({
    super.key,
    required this.userId,
    required this.email,
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
        title: const Text("Đổi mật khẩu", style: TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Email: ${widget.email}", style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),

            _input("Mật khẩu cũ", oldPw),
            const SizedBox(height: 15),
            _input("Mật khẩu mới", newPw),

            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(error!, style: const TextStyle(color: Colors.redAccent)),
              ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: changePassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 45),
              ),
              child: const Text("Xác nhận"),
            )
          ],
        ),
      ),
    );
  }

  Widget _input(String title, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: title,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white12,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> changePassword() async {
    final api = ApiService();

    bool ok = await api.changePassword(
      id: widget.userId,
      oldPw: oldPw.text.trim(),
      newPw: newPw.text.trim(),
    );

    if (!ok) {
      setState(() => error = "Mật khẩu cũ sai hoặc mật khẩu mới không hợp lệ");
    } else {
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }
}