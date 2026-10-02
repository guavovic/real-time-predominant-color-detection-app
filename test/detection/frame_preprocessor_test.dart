import 'dart:typed_data';

import 'package:vera/camera/yuv_frame.dart';
import 'package:vera/detection/frame_preprocessor.dart';
import 'package:flutter_test/flutter_test.dart';

/// Quadro de 4x2 em tons de cinza (U e V neutros), com o brilho de cada pixel:
///
///     10 20 30 40
///     50 60 70 80
YuvFrame grayFrame() => YuvFrame(
  width: 4,
  height: 2,
  yBytes: Uint8List.fromList(<int>[10, 20, 30, 40, 50, 60, 70, 80]),
  yRowStride: 4,
  uBytes: Uint8List.fromList(<int>[128, 128]),
  vBytes: Uint8List.fromList(<int>[128, 128]),
  uvRowStride: 2,
  uvPixelStride: 1,
);

/// O brilho de cada pixel (o canal vermelho) da saída RGB.
List<int> brightness(Uint8List rgb) => <int>[
  for (var i = 0; i < rgb.length; i += 3) rgb[i],
];

void main() {
  group('preprocessFrame', () {
    test('sem rotação, só reduz o quadro', () {
      final out = preprocessFrame(grayFrame(), size: 2);

      expect(brightness(out), <int>[20, 40, 60, 80]);
    });

    test('girando 90 graus, a linha de cima vira a coluna da direita', () {
      final out = preprocessFrame(grayFrame(), size: 2, rotation: 90);

      expect(brightness(out), <int>[60, 20, 80, 40]);
    });

    test('girando 180 graus, o quadro fica de cabeça para baixo', () {
      final out = preprocessFrame(grayFrame(), size: 2, rotation: 180);

      expect(brightness(out), <int>[80, 60, 40, 20]);
    });

    test('girando 270 graus, a linha de cima vira a coluna da esquerda', () {
      final out = preprocessFrame(grayFrame(), size: 2, rotation: 270);

      expect(brightness(out), <int>[40, 80, 20, 60]);
    });

    test('devolve 3 bytes por pixel, com os três canais iguais no cinza', () {
      final out = preprocessFrame(grayFrame(), size: 2);

      expect(out.length, 2 * 2 * 3);
      expect(out.sublist(0, 3), <int>[20, 20, 20]);
    });
  });
}
