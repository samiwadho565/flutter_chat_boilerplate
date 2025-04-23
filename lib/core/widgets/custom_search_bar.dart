import 'package:flutter/material.dart';


class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;


  const CustomSearchBar({
    Key? key,
 this.controller,

  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(

        decoration: BoxDecoration(

        ),
        child: Row(
          children: [
            // TextField
            Expanded(
              child: TextField(
                controller: widget.controller,

                textInputAction: TextInputAction.search, // 👈 This shows "Done" on the keyboard
                decoration: InputDecoration(
                  hintText: 'Search',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

            ),

          ],
        ),
      ),
    );
  }
}
