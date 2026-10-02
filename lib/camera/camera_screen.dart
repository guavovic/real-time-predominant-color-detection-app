import 'package:camera/camera.dart';
import 'package:vera/camera/yuv_frame.dart';
import 'package:vera/detection/detection.dart';
import 'package:vera/detection/detections_painter.dart';
import 'package:vera/detection/object_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Câmera traseira ao vivo em tela cheia, com os objetos marcados na imagem.
/// Tocar na tela fala o que a câmera está vendo.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  static const int _maxSpoken = 3;

  final FlutterTts _tts = FlutterTts();

  ObjectDetector? _detector;
  CameraController? _controller;
  int _sensorOrientation = 0;
  List<Detection> _detections = const <Detection>[];
  String? _error;
  bool _analyzing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _openCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _detector?.close();
    _tts.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _closeCamera();
    } else if (state == AppLifecycleState.resumed) {
      _openCamera();
    }
  }

  Future<void> _openCamera() async {
    if (_controller != null) {
      return;
    }
    try {
      _detector ??= await ObjectDetector.load();
      final cameras = await availableCameras();
      final back = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        back,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _controller = controller;
      _sensorOrientation = back.sensorOrientation;
      await controller.initialize();
      await controller.startImageStream(_onFrame);
      if (!mounted) {
        return;
      }
      setState(() => _error = null);
    } on CameraException catch (e) {
      _controller = null;
      final denied = e.code.startsWith('CameraAccess');
      await _fail(
        denied
            ? 'Sem permissão para usar a câmera. Ative a câmera nas '
                  'configurações do aparelho.'
            : 'Não foi possível abrir a câmera.',
      );
    } on StateError {
      _controller = null;
      await _fail('Este aparelho não tem câmera.');
    } on Object {
      _controller = null;
      await _fail('Não foi possível abrir a câmera.');
    }
  }

  void _onFrame(CameraImage image) {
    final detector = _detector;
    if (_analyzing || detector == null || !mounted) {
      return;
    }
    _analyzing = true;
    try {
      final found = detector.detect(
        YuvFrame.fromCameraImage(image),
        rotation: _sensorOrientation,
      );
      setState(() => _detections = found);
    } finally {
      _analyzing = false;
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    _controller = null;
    _detections = const <Detection>[];
    if (mounted) {
      setState(() {});
    }
    await controller?.dispose();
  }

  Future<void> _fail(String message) async {
    if (!mounted) {
      return;
    }
    setState(() => _error = message);
    await _speak(message);
  }

  Future<void> _speakWhatISee() async {
    if (_detections.isEmpty) {
      await _speak('Não encontrei nada.');
      return;
    }
    final biggest = List<Detection>.of(_detections)
      ..sort(
        (a, b) =>
            (b.box.width * b.box.height).compareTo(a.box.width * a.box.height),
      );
    await _speak(biggest.take(_maxSpoken).map((d) => d.description).join('. '));
  }

  Future<void> _speak(String text) async {
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.8);
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final ready = controller != null && controller.value.isInitialized;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              )
            : !ready
            ? const Center(child: CircularProgressIndicator())
            : Semantics(
                button: true,
                label: 'Câmera ao vivo. Toque para ouvir o que está à frente.',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _speakWhatISee,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1 / controller.value.aspectRatio,
                      child: Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          CameraPreview(controller),
                          CustomPaint(painter: DetectionsPainter(_detections)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
