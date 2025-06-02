import 'package:flutter/material.dart';
import '../widgets/widgets_pagina_inicial/pagina_inicial.dart';
import 'login_screen.dart'; // Importa LoginScreen


class InicioScreen extends StatefulWidget {
  const InicioScreen({Key? key}) : super(key: key);

  @override
  _InicioScreenState createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  @override
  void initState() {
    super.initState();
    // Navegar a LoginScreen después de 3 segundos
    Future.delayed(const Duration(seconds: 10), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PaginaInicial(), // Mostrar la pantalla de inicio
      ),
    );
  }
}