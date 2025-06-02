/*import 'package:flutter/material.dart';
import '../../screens/homepage.dart'; // Importa la pantalla de inicio
import '../../screens/pacientes_ecg_screen.dart'; // Importa la pantalla de pacientes ECG

class SearchBar extends StatelessWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Color(0xFFA7A7A7),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/search_icon.png', // Reemplaza con la ruta correcta
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'search...',
                hintStyle: TextStyle(
                  fontFamily: 'Inria Serif',
                  fontSize: 14,
                  color: Colors.black,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(
                fontFamily: 'Inria Serif',
                fontSize: 14,
                color: Colors.black,
              ),
              onSubmitted: (value) {
                if (value.toLowerCase() == 'home') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Homepage(),
                    ),
                  );
                } else if (value.toLowerCase() == 'ecg') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PacientesEcgScreen(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}*/