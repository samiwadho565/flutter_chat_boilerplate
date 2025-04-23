import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/models/userModel.dart';
import 'package:flutter_chat_boilerplate/core/services/local_storage_service.dart';
import 'package:flutter_chat_boilerplate/core/utils/app_utils.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_back_arrow.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_button.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:get/get.dart';
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  bool _isLoading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final data = await _userService.getCurrentUserData();
    if (data != null) {
      setState(() {
        _user = UserModel.fromMap(data);
        _nameController.text = _user?.name ?? '';
        _aboutController.text = _user?.about ?? '';
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    final success = await _userService.updateUserProfile(
      name: _nameController.text.trim(),
      about: _aboutController.text.trim(),
    );
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Profile updated successfully')),
      );
    } else {
      SnackBar(content: Text('❌ Failed to update profile'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomBackArrow(
            onTap: (){
              Get.back();
            },

          ),
        ),
        title: const Text('Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => AppUtils.logoutUser(),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : _user == null
          ? const Center(child: Text('User not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [

            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: Get.size.height*0.09,),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(5, 0),
                      ),
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Container(),

                      const SizedBox(height: 20),
                      _buildEditableField('Username', _nameController),
                      const Divider(height: 20),

                      _buildEditableField('About', _aboutController,),
                      const Divider(height: 30),
                      Align(
                          alignment: Alignment.centerLeft,
                          child: _buildInfoTile('Email', _user!.email ?? 'N/A')),
                      const Divider(height: 30),
                      SizedBox(height: Get.size.height*0.07,),
                      CustomCupertinoButton(
                        color: Colors.green,
                        text: "Update Profile",
                        onPressed: _updateProfile,
                      ),
                      SizedBox(height: Get.size.height*0.05,),
                    ],
                  ),
                ),

              ],
            ),
            Positioned(
              top: 15,
             left: 130,
              child: CustomCircleAvatar(
                borderColor: Colors.green.shade100,
                radius: 50,
                borderWidth: 3,
                imageUrl:  _user!.profileImage,
              )

            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }

  Widget _buildEditableField(String title, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderSide: BorderSide.none,

            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

