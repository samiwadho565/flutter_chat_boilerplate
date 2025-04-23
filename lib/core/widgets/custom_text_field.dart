import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final VoidCallback? onRecord;
  final bool isRecording;
  final bool paddingZero;
  final String? hintText;
  final Widget? suffixIcon;
  final bool  isForMessageScreen;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    this.onSend,
    this.paddingZero =false,
    this.hintText,
    this.suffixIcon,
    this.isForMessageScreen = false,
 this.onChanged,
    this.onRecord,
    this.isRecording = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool isTextEmpty = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_checkText);
  }

  void _checkText() {
    final isNowEmpty = widget.controller.text.trim().isEmpty;
    if (isNowEmpty != isTextEmpty) {
      setState(() {
        isTextEmpty = isNowEmpty;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_checkText);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding:widget.paddingZero? EdgeInsets.zero: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration:         widget.isForMessageScreen? BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 4),
          ],
        ):null,
        child: Row(
          children: [
            // TextField
            Expanded(
              child: TextField(
                controller: widget.controller,
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                cursorColor:Colors.green,

                onChanged: widget.onChanged,
                decoration: InputDecoration(

                  hintText: widget.hintText?? 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey.shade700),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  suffixIcon:!widget.isForMessageScreen? widget.suffixIcon:null,
                  suffixIconColor: Colors.black,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(

                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Action button (Send / Mic)
          widget.isForMessageScreen?  Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isTextEmpty
                    ? widget.isRecording
                    ? const Icon(Icons.mic, color: Colors.red)
                    : IconButton(
                  icon: const Icon(Icons.mic_none, color: Colors.black87),
                  onPressed: widget.onRecord,
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                )
                    : IconButton(
                  icon: const Icon(Icons.send, color: Colors.black87),
                  onPressed: widget.onSend,
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                ),
              ),
            ):SizedBox(),
          ],
        ),
      ),
    );
  }
}
