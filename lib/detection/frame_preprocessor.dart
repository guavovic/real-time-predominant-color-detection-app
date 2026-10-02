import 'dart:typed_data';

import 'package:vera/camera/yuv.dart';
import 'package:vera/camera/yuv_frame.dart';

/// Prepara um quadro da câmera para o detector: gira para ficar em pé,
/// reduz para [size] x [size] e entrega os pixels em RGB, 3 bytes cada.
///
/// [rotation] é quanto o quadro precisa girar no sentido horário (0, 90, 180
/// ou 270) para ficar como a pessoa vê a tela. É a orientação do sensor.
Uint8List preprocessFrame(
  YuvFrame frame, {
  required int size,
  int rotation = 0,
}) {
  final out = Uint8List(size * size * 3);
  var offset = 0;
  for (var oy = 0; oy < size; oy++) {
    final ny = (oy + 0.5) / size;
    for (var ox = 0; ox < size; ox++) {
      final nx = (ox + 0.5) / size;
      final (double fx, double fy) = switch (rotation) {
        90 => (ny, 1 - nx),
        180 => (1 - nx, 1 - ny),
        270 => (1 - ny, nx),
        _ => (nx, ny),
      };
      final sx = (fx * frame.width).floor().clamp(0, frame.width - 1);
      final sy = (fy * frame.height).floor().clamp(0, frame.height - 1);

      final y = frame.yBytes[sy * frame.yRowStride + sx];
      final uvIndex =
          (sy ~/ 2) * frame.uvRowStride + (sx ~/ 2) * frame.uvPixelStride;
      final rgb = yuvToRgb(y, frame.uBytes[uvIndex], frame.vBytes[uvIndex]);
      out[offset++] = rgb.red;
      out[offset++] = rgb.green;
      out[offset++] = rgb.blue;
    }
  }
  return out;
}
