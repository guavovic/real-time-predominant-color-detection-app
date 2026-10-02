import 'package:camera/camera.dart';
import 'package:camera_cor_destaque/camera/frame_color.dart';
import 'package:camera_cor_destaque/color/color_namer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Câmera traseira ao vivo em tela cheia. Tocar na tela fala a cor do centro.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  final FlutterTts _tts = FlutterTts();
  final ColorNamer _namer = ColorNamer();

  CameraController? _controller;
  CameraImage? _lastFrame;
  String? _error;
  String _detectedColor = '';

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
      await controller.initialize();
      await controller.startImageStream((frame) => _lastFrame = frame);
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
    } on Exception {
      _controller = null;
      await _fail('Não foi possível abrir a câmera.');
    }
  }

  Future<void> _closeCamera() async {
    final controller = _controller;
    _controller = null;
    _lastFrame = null;
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

  Future<void> _speakColor() async {
    final frame = _lastFrame;
    if (frame == null) {
      return;
    }
    final rgb = centerColor(frame);
    final name = _namer.nameOf(rgb.red, rgb.green, rgb.blue);
    setState(() => _detectedColor = name);
    await _speak(name);
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
                label: 'Câmera ao vivo. Toque para ouvir a cor do centro.',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _speakColor,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      Center(child: CameraPreview(controller)),
                      if (_detectedColor.isNotEmpty)
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: double.infinity,
                            color: Colors.black,
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              _detectedColor,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
