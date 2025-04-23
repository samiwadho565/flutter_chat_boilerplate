import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/SignInScreen.dart';
import 'package:get/get.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  final String email;

  const PasswordResetSuccessScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 20),
              Text(
                "Check your email",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "We've sent a password reset link to\n$email\n\n"
                    "📩 If you don't see it in your inbox, please check your Spam or Junk folder.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),

              SizedBox(height: 30),
              CupertinoButton(
                padding: EdgeInsets.symmetric(horizontal: 30,vertical: 2),
                color: Colors.black,
                child: Text("Back to LogIn ",style: TextStyle(color: Colors.white),),
                onPressed: ()async {
              Get.offAll(SignInScreen());
                },),

            ],
          ),
        ),
      ),
    );
  }
}
