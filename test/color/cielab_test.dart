import 'package:vera/color/cielab.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Lab.fromRgb', () {
    test('branco tem luminosidade 100 e nenhuma cor', () {
      final lab = Lab.fromRgb(255, 255, 255);

      expect(lab.l, closeTo(100, 0.01));
      expect(lab.a, closeTo(0, 0.01));
      expect(lab.b, closeTo(0, 0.01));
    });

    test('preto tem luminosidade 0', () {
      expect(Lab.fromRgb(0, 0, 0).l, closeTo(0, 0.001));
    });

    test('vermelho puro bate com os valores de referência', () {
      final lab = Lab.fromRgb(255, 0, 0);

      expect(lab.l, closeTo(53.24, 0.05));
      expect(lab.a, closeTo(80.09, 0.1));
      expect(lab.b, closeTo(67.20, 0.1));
    });

    test('cinza muito escuro usa o trecho linear da conversão', () {
      expect(Lab.fromRgb(10, 10, 10).l, closeTo(2.74, 0.02));
    });

    test('cinza médio bate com o valor de referência', () {
      expect(Lab.fromRgb(128, 128, 128).l, closeTo(53.59, 0.02));
    });

    test('azul puro bate com os valores de referência', () {
      final lab = Lab.fromRgb(0, 0, 255);

      expect(lab.l, closeTo(32.30, 0.05));
      expect(lab.a, closeTo(79.19, 0.1));
      expect(lab.b, closeTo(-107.86, 0.1));
    });
  });

  group('deltaE2000', () {
    // Pares do conjunto de teste de Sharma, Wu e Dalal (2005).
    test('pares de referência', () {
      expect(
        deltaE2000(const Lab(50, 2.6772, -79.7751), const Lab(50, 0, -82.7485)),
        closeTo(2.0425, 0.0001),
      );
      expect(
        deltaE2000(const Lab(50, 3.1571, -77.2803), const Lab(50, 0, -82.7485)),
        closeTo(2.8615, 0.0001),
      );
      expect(
        deltaE2000(const Lab(50, 2.8361, -74.0200), const Lab(50, 0, -82.7485)),
        closeTo(3.4412, 0.0001),
      );
      expect(
        deltaE2000(const Lab(50, 2.5, 0), const Lab(73, 25, -18)),
        closeTo(27.1492, 0.0001),
      );
    });

    test('cores iguais ficam a distância zero', () {
      const lab = Lab(60, 20, -30);

      expect(deltaE2000(lab, lab), 0);
    });

    test('a distância não depende da ordem', () {
      const first = Lab(40, 30, 10);
      const second = Lab(70, -20, 40);

      expect(
        deltaE2000(first, second),
        closeTo(deltaE2000(second, first), 1e-9),
      );
    });
  });
}
