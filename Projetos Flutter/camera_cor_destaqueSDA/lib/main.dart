// @dart=2.12

import 'dart:typed_data';
import 'dart:ui';
import 'package:colornames/colornames.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'WhatColor',
      color: Colors.amberAccent,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
        ),
      ),
      home: const MyHomePage(title: 'WhatColor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  late bool isListening;
  late CameraController cameraController;
  late bool isCameraInitialized;
  late String detectedColor;
  late Timer timer;
  late bool isLoading;
  late Uint8List? takenPhoto;
  bool isPhotoTaken = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    isListening = false;
    isCameraInitialized = false;
    detectedColor = '';
    isLoading = false;
  }

  @override
  void dispose() {
    flutterTts.stop();
    cameraController.dispose();
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: () {
          takePhotoAndProcess();
        },
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Clique na tela para tirar uma foto'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                if (isPhotoTaken)
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                    ),
                    child: Image.memory(
                      takenPhoto!,
                      width: 400,
                      height: 400,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (detectedColor.isNotEmpty)
                  Text(
                    'Cor detectada: $detectedColor'.toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> takePhotoAndProcess() async {
    takenPhoto = null;
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final imageBytes = await pickedImage.readAsBytes();
      final image = img.decodeImage(imageBytes);
      final imageData = img.encodePng(image!);

      final codec = await instantiateImageCodec(imageData);
      final frame = await codec.getNextFrame();
      final inputImage = frame.image;

      final paletteGenerator = await PaletteGenerator.fromImage(inputImage);

      final dominantColor = paletteGenerator.dominantColor?.color;

      if (dominantColor != null) {
        String colorName = await getColorName(dominantColor);

        setState(() {
          detectedColor = colorName;
          isPhotoTaken = true;
          isLoading = true;
        });
        takenPhoto = imageBytes;
        await Future.delayed(const Duration(seconds: 1));
        await speakText('A cor mais dominante na foto é $detectedColor.');
      }
    }
  }
  // Conf da voz
  Future<void> speakText(String text) async {
    await flutterTts.setLanguage('pt-BR');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.speak(text);
  }

   String getColorName(Color color) {
    return ColorNames.guess(color);
  }

  /////////////////////////////////// teste em pt com cores mais genericas
  String getGenereicColorName(Color color) {
    final Map<String, Color> genericColors = {
      'vermelho': const Color(0xFFCC0000),
      'vermelho escuro': const Color(0xFF800000),
      'vermelho claro': const Color(0xFFFF6666),
      'verde': const Color(0xFF009933),
      'verde escuro':const  Color(0xFF006622),
      'verde claro':const  Color(0xFF66FF99),
      'azul': const Color(0xFF0000CC),
      'azul escuro':const Color(0xFF000066),
      'azul claro':const  Color(0xFF6699FF),
      'amarelo':const  Color(0xFFFFD700),
      'amarelo escuro':const  Color(0xFFDAA520),
      'amarelo claro':const  Color(0xFFFFFF99),
      'laranja': const Color(0xFFFFA500),
      'laranja escuro':const  Color(0xFFFF8C00),
      'laranja claro': const Color(0xFFFFD700),
      'roxo':const  Color(0xFF800080),
      'roxo escuro':const  Color(0xFF4B0082),
      'roxo claro': const Color(0xFF9370DB),
      'rosa': const Color(0xFFFF69B4),
      'rosa escuro': const Color(0xFFC71585),
      'rosa claro':const  Color(0xFFFFB6C1),
      'ciano':const  Color(0xFF00CED1),
      'ciano escuro':const  Color(0xFF008B8B),
      'ciano claro':const  Color(0xFFE0FFFF),
      'marrom':const  Color(0xFFA52A2A),
      'cinza':const  Color(0xFF808080),
      'cinza escuro':const  Color(0xFF333333),
      'cinza claro': const Color(0xFFCCCCCC),
    };

    String nearestColorName = 'Nao sei que cor é essa';
    double minDistance = double.infinity;
    final r = color.red.toDouble();
    final g = color.green.toDouble();
    final b = color.blue.toDouble();

    for (final entry in genericColors.entries) {
      final genericColor = entry.value;
      final deltaR = r - genericColor.red.toDouble();
      final deltaG = g - genericColor.green.toDouble();
      final deltaB = b - genericColor.blue.toDouble();
      final distance = deltaR * deltaR + deltaG * deltaG + deltaB * deltaB;
      if (distance < minDistance) {
        minDistance = distance;
        nearestColorName = entry.key;
      }
    }
    return nearestColorName;
  }
}
