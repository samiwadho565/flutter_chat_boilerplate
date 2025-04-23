import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomCircleAvatar extends StatelessWidget {
  final String? imageUrl;
  final bool isLogo;
  final double radius;
  final Color borderColor;
  final double borderWidth;

  const CustomCircleAvatar({
    this.isLogo =false,
 this.imageUrl,
    this.radius = 25,
    this.borderColor = Colors.grey,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2 + borderWidth * 2,
      height: radius * 2 + borderWidth * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: ClipOval(
        child: isLogo?Icon(Icons.person,color: Colors.white,):CachedNetworkImage(
          imageUrl: imageUrl??"",
          fit: BoxFit.cover,
          placeholder: (context, url) => Center(
            child: Container(
              color: Colors.grey,
            )
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
