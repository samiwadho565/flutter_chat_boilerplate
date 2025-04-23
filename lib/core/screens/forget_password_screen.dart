import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/services/auth_services.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_back_arrow.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_text_field.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ForgetPasswordScreen extends StatelessWidget {
  
  final TextEditingController _emailController = TextEditingController();
  final AuthenticationService _authService = AuthenticationService();

  ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(

          children: [
            SizedBox(height: Get.size.height*0.05),
            Align(
              alignment: Alignment.centerLeft,
              child: CustomBackArrow(
                onTap: () {
                  Navigator.pop(context); // Or any other action you want
                },
              ),
            ),

            SizedBox(height: Get.size.height*0.12),
            Text(
              "Please enter your email address. We'll send you a link to reset your password.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: Get.size.height*0.05),
            CustomTextField(
                hintText: "Enter Your email",
                controller: _emailController),
            SizedBox(height: Get.size.height*0.05),
        CupertinoButton(
          padding: EdgeInsets.symmetric(horizontal: 30,vertical: 2),
          color: Colors.black,
          child: Text("Submit",style: TextStyle(color: Colors.white),),
          onPressed: ()async {
            final email = _emailController.text.trim();
            if (email.isEmpty) {

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please enter your email first!')),
              );
              return;
            }

            try {

              await _authService.resetPassword(email);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ Failed to send reset link')),
              );
            }
          },),
            // SizedBox(height: Get.size.height/2.5,)
          ],
        ),
      ),

    );

  }
}
