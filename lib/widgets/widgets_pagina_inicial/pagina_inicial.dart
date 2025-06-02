import 'package:aplicacion_guli/screens/login_screen.dart';
import 'package:flutter/material.dart';

class PaginaInicial extends StatelessWidget {
  const PaginaInicial({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        // Navegar a LoginScreen al presionar cualquier parte de la pantalla
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        constraints: const BoxConstraints(maxWidth: 480), // Ancho máximo de 480 (como un celular)
          
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                constraints: BoxConstraints(
                  maxWidth: screenWidth * 0.8, // 80% del ancho de la pantalla
                  maxHeight: screenHeight * 0.8, // 80% del alto de la pantalla
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1, // 10% del ancho de la pantalla
                  vertical: screenHeight * 0.1, // 10% del alto de la pantalla
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png', // Ruta de la imagen local
                      width: constraints.maxWidth * 0.2, // 50% del ancho disponible
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}