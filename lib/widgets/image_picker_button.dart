// lib/widgets/image_picker_button.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerButton extends StatelessWidget {
  final String? imagePath;
  final Function(String?) onImagePicked;
  final IconData defaultIcon;

  const ImagePickerButton({
    super.key,
    required this.imagePath,
    required this.onImagePicked,
    this.defaultIcon = Icons.add_a_photo,
  });

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        // CORREÇÃO: Adicionado Padding para respeitar a área de segurança inferior
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Selecionar da Galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
                  if (pickedFile != null) {
                    onImagePicked(pickedFile.path);
                  }
                },
              ),
              if (imagePath != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.redAccent),
                  title: const Text('Remover Imagem', style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.of(context).pop();
                    onImagePicked(null);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pickImage(context),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[700],
        backgroundImage: imagePath != null && File(imagePath!).existsSync()
            ? FileImage(File(imagePath!))
            : null,
        child: imagePath == null || !File(imagePath!).existsSync()
            ? Icon(defaultIcon, size: 50, color: Colors.white)
            : null,
      ),
    );
  }
}
