import 'package:flutter/material.dart';
import 'activity_login.dart';
import 'activity_register.dart';

class LoginOptionsScreen extends StatelessWidget {
  const LoginOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.of(context).size.width;
    final double horizontalPadding = w * 0.05;
    final double fontSizeTitle = w * 0.06;
    final double fontSizeButton = w * 0.045;
    final double logoSize = 300.0;
    final double buttonHeight = 56.0;
    final double spacingSmall = 16.0;
    final double spacingMedium = 24.0;
    final double spacingLarge = 32.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/img/logo.png",
                                height: logoSize,
                                width: logoSize,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(height: spacingMedium),
                              Text(
                                "Chào mừng đến với My Music",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: spacingLarge),

                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SignUpScreen()),
                              );
                            },
                            icon: const Icon(Icons.email, color: Colors.white),
                            label: Text(
                              "Đăng ký miễn phí",
                              style: TextStyle(
                                fontSize: fontSizeButton,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1DB954),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: spacingSmall),

                        SizedBox(
                          width: double.infinity,
                          height: buttonHeight,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            icon: const Icon(Icons.login, color: Colors.white),
                            label: Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: fontSizeButton,
                                color: Colors.white,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 1.3),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: spacingLarge),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}