import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 145, // Ancho fijo
      height: 125, // Alto fijo
      child: Image.network(
        "https://cdn.builder.io/api/v1/image/assets/07b7b4c075d4456b854e11b352f3a209/ca609405f498f03c04bfff4fd6151911e41891dbd5f46abba9c35297b616a9b1?placeholderIfAbsent=true",
        fit: BoxFit.contain, // Ajusta la imagen al tamaño del contenedor
      ),
    );
  }
}