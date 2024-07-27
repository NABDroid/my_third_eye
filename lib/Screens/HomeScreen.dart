import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String? response;
  final XFile? image;
  const HomeScreen({super.key, this.response, this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: (image == null)
              ? const Text("No Image")
              : Image.file(File(image!.path)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(response??"No response!"),
        ),
      ],
    );
  }
}
