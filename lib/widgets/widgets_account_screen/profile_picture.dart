import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class ProfilePicture extends StatelessWidget {
  const ProfilePicture({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Aquí debes agregar la lógica para subir una foto de perfil
        /*
        final imagePicker = ImagePicker();
        final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          final response = await http.post(
            Uri.parse('https://tuservidor.com/api/subirFotoPerfil'),
            body: {
              'image': pickedFile.path,
            },
          );

          if (response.statusCode == 200) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Foto de perfil actualizada correctamente.',
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error al subir la foto de perfil.',
                ),
              ),
            );
          }
        }
        */
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: AppColors.primary,
        child: const Icon(
          Icons.person,
          size: 50,
          color: AppColors.white,
        ),
      ),
    );
  }
}