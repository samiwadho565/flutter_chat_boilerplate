import 'package:flutter/material.dart';

class CustomBackArrow extends StatelessWidget {
  final Function()? onTap;

  CustomBackArrow({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.0,
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white,
          size: 24.0, // Icon size
        ),
      ),
    );
  }
}
