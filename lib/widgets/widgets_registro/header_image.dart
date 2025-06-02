import 'package:flutter/material.dart';

class HeaderImage extends StatelessWidget {
  final VoidCallback onClosePressed; // Callback para el botón de "X"

  const HeaderImage({Key? key, required this.onClosePressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(78, 20, 78, 13), // Reducir el padding superior de 51 a 20
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: Color(0xFFCEAAC1),
          ),
          child: Column(
            children: [
              Container(
            margin: const EdgeInsets.only(top: 10), // Ajusta la posición del logo
            child: Image.asset(
              'assets/images/logo.png', // Ruta de la imagen local
              width: 50, // Ajusta el ancho según sea necesario
              height: 50, // Ajusta la altura según sea necesario
            ),
          ),
            ],
          ),
        ),

        // Botón de "X" en la esquina superior izquierda
        Positioned(
          top: 35,
          left: 5,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Color(0xFFFF22AE)),
            onPressed: onClosePressed,
          ),
        ),
      ],
    );
  }
}