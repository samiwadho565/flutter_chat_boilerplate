import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/conversation_screen.dart';
import 'package:flutter_chat_boilerplate/core/screens/forget_password_screen.dart';
import 'package:flutter_chat_boilerplate/core/screens/sign_up_screen.dart';
import 'package:flutter_chat_boilerplate/core/services/auth_services.dart';
import 'package:flutter_chat_boilerplate/core/services/local_storage_service.dart';
import 'package:flutter_chat_boilerplate/core/utils/app_utils.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_button.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_text_field.dart';
import 'package:get/get.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreen createState() => _SignInScreen();
}

class _SignInScreen extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthenticationService _authService = AuthenticationService();

  String _errorMessage = '';

  void _signIn() async {
    AppUtils.showLoadingDialog();

    setState(() {
      _errorMessage = '';
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required!';
        AppUtils.hideLoadingDialog();
      });
      return;
    }

    try {
      final userCredential = await _authService.signInWithEmailAndPassword(email: email, password: password);
      AppUtils.hideLoadingDialog();

      if (userCredential != null) {
        final currentUserId = userCredential.user?.uid;
        print("✅ login SuccessFully ${userCredential.user?.photoURL }");
        await LocalStorageService.setUserId(currentUserId!);
        await LocalStorageService.setProfileImage(userCredential.user?.photoURL ?? '');

        Get.off(() => ConversationsScreen(currentUserId: currentUserId));
      } else {
        setState(() {
          _errorMessage = 'Sign up failed. Please try again.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var rand = Random().nextInt(10000);

    _emailController.text = "user9210@gmail.com";
    _passwordController.text = "123456";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(height:Get.size.height*0.21,),
              Center(child: const Text('Sign In', style: TextStyle(fontSize: 20))),
              SizedBox(height: 50),
              CustomTextField(
                paddingZero: true,
                controller: _emailController,
                hintText: "Email",
                suffixIcon: Icon(Icons.email),
              ),
              CustomTextField(
                paddingZero: true,
                controller: _passwordController,
                hintText: "Password",
                suffixIcon: Icon(Icons.password),
              ),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Get.to(() => ForgetPasswordScreen());
                  },
                  child: Text(
                    "Forget Password?",
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ),
              SizedBox(height: 100),
            CustomCupertinoButton(
              text: "Sign In",
              onPressed: _signIn,
            ),
              SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              // "Don't have an account? Sign Up" Text
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.to(() => SignUpScreen());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Sign Up",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
