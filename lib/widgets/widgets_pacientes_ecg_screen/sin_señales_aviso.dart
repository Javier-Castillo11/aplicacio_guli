import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';

class SinSenalesAviso extends StatelessWidget {
  const SinSenalesAviso({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off, // Icono de señal no disponible
            size: 50,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 16),
          Text(
            languageProvider.currentLanguage == 'es'
                ? 'No se han recibido señales aún'
                : 'No signals have been received yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: 'Inria Serif',
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.currentLanguage == 'es'
                ? 'Por favor, revisa más tarde.'
                : 'Please check back later.',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}