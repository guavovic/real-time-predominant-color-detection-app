import 'dart:typed_data';

import 'package:camera/camera.dart';

/// Um quadro da câmera em YUV 4:2:0, só com o que a análise precisa.
class YuvFrame {
  const YuvFrame({
    required this.width,
    required this.height,
    required this.yBytes,
    required this.yRowStride,
    required this.uBytes,
    required this.vBytes,
    required this.uvRowStride,
    required this.uvPixelStride,
  });

  factory YuvFrame.fromCameraImage(CameraImage image) {
    final y = image.planes[0];
    final u = image.planes[1];
    final v = image.planes[2];
    return YuvFrame(
      width: image.width,
      height: image.height,
      yBytes: y.bytes,
      yRowStride: y.bytesPerRow,
      uBytes: u.bytes,
      vBytes: v.bytes,
      uvRowStride: u.bytesPerRow,
      uvPixelStride: u.bytesPerPixel ?? 1,
    );
  }

  final int width;
  final int height;
  final Uint8List yBytes;
  final int yRowStride;
  final Uint8List uBytes;
  final Uint8List vBytes;
  final int uvRowStride;
  final int uvPixelStride;
}
