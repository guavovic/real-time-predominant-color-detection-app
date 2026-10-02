import 'package:camera_cor_destaque/color/color_namer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:palette_generator/palette_generator.dart';

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
      home: const MyHomePage(title: 'WhatColor'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts _tts = FlutterTts();
  final ColorNamer _namer = ColorNamer();
  String _detectedColor = '';

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _takePhotoAndProcess() async {
    final photo = await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo == null) {
      return;
    }

    final palette = await PaletteGenerator.fromImageProvider(
      MemoryImage(await photo.readAsBytes()),
    );
    final dominant = palette.dominantColor?.color;
    if (dominant == null) {
      return;
    }

    final argb = dominant.toARGB32();
    final name = _namer.nameOf(
      (argb >> 16) & 0xFF,
      (argb >> 8) & 0xFF,
      argb & 0xFF,
    );
    setState(() => _detectedColor = name);

    await Future<void>.delayed(const Duration(seconds: 1));
    await _speak('A cor mais dominante na foto é $name.');
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('pt-BR');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.8);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: GestureDetector(
        onTap: _takePhotoAndProcess,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Clique na tela para tirar uma foto',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              if (_detectedColor.isNotEmpty)
                Text(
                  'Cor detectada: $_detectedColor',
                  style: const TextStyle(fontSize: 20),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
