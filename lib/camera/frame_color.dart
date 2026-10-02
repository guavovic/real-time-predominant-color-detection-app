import 'package:camera/camera.dart';
import 'package:camera_cor_destaque/camera/yuv.dart';

/// A cor média de um quadrado no centro do [image], que deve estar em YUV 4:2:0.
///
/// [fraction] é o lado do quadrado como parte do menor lado da imagem.
({int red, int green, int blue}) centerColor(
  CameraImage image, {
  double fraction = 0.1,
}) {
  final yPlane = image.planes[0];
  final uPlane = image.planes[1];
  final vPlane = image.planes[2];

  final shortSide = image.width < image.height ? image.width : image.height;
  final half = shortSide * fraction / 2;
  final left = (image.width / 2 - half).floor().clamp(0, image.width - 1);
  final right = (image.width / 2 + half).ceil().clamp(left + 1, image.width);
  final top = (image.height / 2 - half).floor().clamp(0, image.height - 1);
  final bottom = (image.height / 2 + half).ceil().clamp(top + 1, image.height);

  final uvPixelStride = uPlane.bytesPerPixel ?? 1;
  var red = 0;
  var green = 0;
  var blue = 0;
  var count = 0;
  for (var row = top; row < bottom; row++) {
    for (var col = left; col < right; col++) {
      final y = yPlane.bytes[row * yPlane.bytesPerRow + col];
      final uvRow = row ~/ 2;
      final uvOffset = (col ~/ 2) * uvPixelStride;
      final u = uPlane.bytes[uvRow * uPlane.bytesPerRow + uvOffset];
      final v = vPlane.bytes[uvRow * vPlane.bytesPerRow + uvOffset];
      final rgb = yuvToRgb(y, u, v);
      red += rgb.red;
      green += rgb.green;
      blue += rgb.blue;
      count++;
    }
  }
  return (red: red ~/ count, green: green ~/ count, blue: blue ~/ count);
}
