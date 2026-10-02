import 'package:vera/camera/yuv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('yuvToRgb', () {
    test('cinza neutro mantém o brilho nos três canais', () {
      expect(yuvToRgb(100, 128, 128), (red: 100, green: 100, blue: 100));
    });

    test('preto e branco', () {
      expect(yuvToRgb(0, 128, 128), (red: 0, green: 0, blue: 0));
      expect(yuvToRgb(255, 128, 128), (red: 255, green: 255, blue: 255));
    });

    test('vermelho puro', () {
      final rgb = yuvToRgb(76, 85, 255);
      expect(rgb.red, greaterThan(250));
      expect(rgb.green, lessThan(5));
      expect(rgb.blue, lessThan(5));
    });

    test('azul puro', () {
      final rgb = yuvToRgb(29, 255, 107);
      expect(rgb.blue, greaterThan(250));
      expect(rgb.red, lessThan(5));
    });

    test('limita os canais entre 0 e 255', () {
      final rgb = yuvToRgb(255, 0, 255);
      expect(rgb.red, 255);
      expect(rgb.green, inInclusiveRange(0, 255));
      expect(rgb.blue, inInclusiveRange(0, 255));
    });
  });
}
