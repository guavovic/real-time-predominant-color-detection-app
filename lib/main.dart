import 'package:camera_cor_destaque/camera/camera_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatColor',
      theme: ThemeData(colorSchemeSeed: Colors.blue),
      home: const CameraScreen(),
    );
  }
}
