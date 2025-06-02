import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class BackButton extends StatelessWidget {
  const BackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary),
      onPressed: () {
        Navigator.pop(context); // Regresa a la pantalla anterior
      },
    );
  }
}