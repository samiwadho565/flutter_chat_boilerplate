import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/conversation_screen.dart';
import 'package:flutter_chat_boilerplate/core/screens/SignInScreen.dart';
import 'package:flutter_chat_boilerplate/core/services/local_storage_service.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash delay

    final userId = await LocalStorageService.getUserId();
    if (userId != null && userId.isNotEmpty) {
      Get.off(() => ConversationsScreen(currentUserId: userId));
    } else {
      Get.off(() => SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.5, end: 1.0),
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOutBack,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: const Text(
                  "🗨️ Flutter Chat",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ));
  }
}
