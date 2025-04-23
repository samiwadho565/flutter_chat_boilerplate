import 'package:flutter/material.dart';
import 'package:flutter_chat_boilerplate/core/screens/user_profile_screen.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_circular_image.dart';
import 'package:flutter_chat_boilerplate/core/widgets/custom_search_bar.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final  bool isBackArrow;
   const CustomAppBar({
     this.isBackArrow = false,
    required this.title,
    super.key});

  @override
  Size get preferredSize => const Size.fromHeight(130);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 12),
      color: Colors.black,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  [
            Row(
              children: [
                isBackArrow?GestureDetector(
                  onTap: (){
                    Get.back();
                  },
                    child: Icon(Icons.arrow_back_ios_sharp,color: Colors.white,)):SizedBox(),

              SizedBox(width:  isBackArrow? 20:0,)  , Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                GestureDetector(
                    onTap: (){
                      Get.to(() => ProfileScreen());

                    },
                    child: CustomCircleAvatar(
                        isLogo: true,
                        radius: 18,
                        )),

              ],
            ),
            SizedBox(height: 15),
            CustomSearchBar(),
          ],
        ),
      ),
    );
  }
}
