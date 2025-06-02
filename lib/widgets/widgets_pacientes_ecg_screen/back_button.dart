import 'package:flutter/material.dart';

class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF22AE)),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }
}