import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/SignInScreen.dart';
import 'package:flutter_chat_boilerplate/core/screens/conversation_screen.dart';
import 'package:flutter_chat_boilerplate/core/services/auth_services.dart';
import 'package:flutter_chat_boilerplate/core/utils/app_utils.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_back_arrow.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_button.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';


class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();

  final AuthenticationService _authService = AuthenticationService();

  bool _isLoading = false;
  String _errorMessage = '';

  void _signUp() async {

    AppUtils.showLoadingDialog();

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() {
        AppUtils.hideLoadingDialog();// 👈 Hide the loader popup

        _errorMessage = 'All fields are required!';
        _isLoading = false;
      });
      return;
    }

   try {
      final userCredential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        username: username,
      );
      AppUtils.hideLoadingDialog();// 👈 Hide the loader popup

      if (userCredential != null) {
        SnackBar(content: Text('✅ Account Created successfully'));

        Get.off(() => SignInScreen());
      } else {
        setState(() {
          _errorMessage = 'Sign up failed. Please try again.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }


  String generateRandomUsername() {
    final names = [
      'Harry',
      'JackSparrow',
      'Olivia',
      'Liam',
      'Emma',
      'Noah',
      'Sophia',
      'Mason',
      'Ava',
      'Ethan',
      'Isabella',
      'Lucas',
      'Mia',
      'Logan',
      'Amelia',
      'James',
      'Charlotte',
      'Benjamin',
      'Elijah',
      'Jack',
      'Luna',
    ];

    final rand = Random();
    return names[rand.nextInt(names.length)];
  }

  @override
  Widget build(BuildContext context) {
    final randUsername = generateRandomUsername();

    var rand = Random().nextInt(10000);

    String randomDigits = (100 + Random().nextInt(900)).toString(); // ✅ Another random

    _emailController.text =  "${randUsername}${rand}@gmail.com";
    _usernameController.text =  "${randUsername}${randomDigits}";
    _passwordController.text =  "123456";



    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: const Text('Sign Up'),
      // ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height:Get.size.height*0.05,),
              Align(
                alignment: Alignment.centerLeft,
                child: CustomBackArrow(
                  onTap: () {
                    // Handle back action
                    Navigator.pop(context); // Or any other action you want
                  },
                ),
              ),
              SizedBox(height:Get.size.height*0.1,),
              Center(child: const Text('Sign Up',style: TextStyle(fontSize: 20),)),
              SizedBox(height: 50,),
              CustomTextField(
          paddingZero: true,
                  controller: _usernameController,
            hintText: "User Name",
                suffixIcon: Icon(Icons.person)
                ),
          CustomTextField(
            paddingZero: true,
          controller: _emailController,
          hintText: "Email",
            suffixIcon: Icon(Icons.email),
                ),
              // const SizedBox(height: 10),
            CustomTextField(
              paddingZero: true,
              controller: _passwordController,
          hintText:
              "Password",
              suffixIcon: Icon(Icons.password),
            ),

              const SizedBox(height: 100),

              CustomCupertinoButton(
                text: "Sign Up",
                onPressed: _signUp,
              ),


              SizedBox(height: 20,),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an Account?",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Sign In",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
