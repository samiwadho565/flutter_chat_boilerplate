import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/SignInScreen.dart';
import 'package:get/get.dart';
import '../services/local_storage_service.dart';

class AppUtils {

  static void showLoadingDialog() {
    Get.dialog(
      Center(
        child: Container(
          width: 100,
          height: 100,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Padding(
            padding: EdgeInsets.all(18.0),
            child: CircularProgressIndicator(color: Colors.black),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void hideLoadingDialog() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }


  static Future<void> logoutUser() async {
    final shouldLogout = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel",style: TextStyle(color: Colors.black),),
          ),
          TextButton(
            onPressed: () =>  Get.back(result: true),
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    if (shouldLogout == true) {
      showLoadingDialog();
      await Future.delayed(const Duration(milliseconds: 500));
      await LocalStorageService.clearUserData();
      hideLoadingDialog();
    Get.offAll(() => SignInScreen());
    }
  }

}
