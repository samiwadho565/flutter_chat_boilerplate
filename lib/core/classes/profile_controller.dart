import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  RxString profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();

    loadProfileImage();
  }

  void loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    print("daa load${ prefs.getString('profileImage')}");
    profileImage.value = prefs.getString('profileImage') ?? '';
  }
}
