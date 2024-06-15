// @dart=2.12

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

//============================================================================
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title:'WhatColor',
      color: Colors.amberAccent,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'WhatColor'),
    );
  }
}

//============================================================================
class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

//============================================================================
class _MyHomePageState extends State<MyHomePage> {
  late FlutterTts flutterTts;
  late bool isListening;
  late CameraController cameraController;
  late bool isCameraInitialized;
  late String detectedColor;
  late Timer timer;
  late bool isLoading;

  //============================================================================
  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    isListening = false;
    isCameraInitialized = false;
    detectedColor = '';
    isLoading = false;
  }

  //============================================================================
  @override
  void dispose() {
    flutterTts.stop();
    cameraController.dispose();
    timer.cancel();
    super.dispose();
  }

  //============================================================================
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Clique na tela para tirar uma foto',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (detectedColor.isNotEmpty)
                Text(
                  'Cor detectada: $detectedColor',
                  style: const TextStyle(fontSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> takePhotoAndProcess() async {
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
          isLoading = false; // Define isLoading como false após obter a cor
        });

        print('A cor mais dominante na foto é $detectedColor.');

        await Future.delayed(const Duration(seconds: 1));
        await speakText('A cor mais dominante na foto é $detectedColor.');
      }
    }
  }

  //============================================================================
  // Configuração da voz
  Future<void> speakText(String text) async {
    await flutterTts.setLanguage('pt-BR');
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.8);
    await flutterTts.speak(text);
  }

  //============================================================================
  String getColorName(Color color) {
    return ColorNames.guess(color);
  }

  //============================================================================
}
