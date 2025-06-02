import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  const HeaderImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Color(0xFFCEAAC1), // Fondo rosa
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo.png', // Reemplaza con la ruta correcta
          width: 100,
          height: 100,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}