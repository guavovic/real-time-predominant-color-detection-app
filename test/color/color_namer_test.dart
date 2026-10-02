import 'package:camera_cor_destaque/color/cielab.dart';
import 'package:camera_cor_destaque/color/color_namer.dart';
import 'package:camera_cor_destaque/color/palette.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final namer = ColorNamer();

  group('ColorNamer', () {
    test('cada cor de referência recebe o próprio nome', () {
      for (final color in portuguesePalette) {
        expect(
          namer.nameOf(color.red, color.green, color.blue),
          color.name,
          reason: 'referência ${color.name}',
        );
      }
    });

    test('cores puras recebem o nome que uma pessoa daria', () {
      expect(namer.nameOf(255, 0, 0), 'vermelho');
      expect(namer.nameOf(0, 255, 0), 'verde');
      expect(namer.nameOf(0, 0, 255), 'azul');
      expect(namer.nameOf(255, 255, 0), 'amarelo');
      expect(namer.nameOf(0, 0, 0), 'preto');
      expect(namer.nameOf(255, 255, 255), 'branco');
    });

    test('tons de cinza', () {
      expect(namer.nameOf(25, 25, 28), 'preto');
      expect(namer.nameOf(70, 70, 72), 'cinza escuro');
      expect(namer.nameOf(128, 128, 128), 'cinza');
      expect(namer.nameOf(200, 200, 205), 'cinza claro');
    });

    test('claro e escuro de uma mesma cor', () {
      expect(namer.nameOf(135, 206, 235), 'azul claro');
      expect(namer.nameOf(0, 0, 139), 'azul escuro');
      expect(namer.nameOf(0, 100, 0), 'verde escuro');
      expect(namer.nameOf(128, 0, 0), 'vermelho escuro');
    });

    test('cores que não são só matiz: marrom, bege, rosa, laranja', () {
      expect(namer.nameOf(139, 69, 19), 'marrom');
      expect(namer.nameOf(210, 180, 140), 'bege');
      expect(namer.nameOf(255, 192, 203), 'rosa claro');
      expect(namer.nameOf(255, 105, 180), 'rosa');
      expect(namer.nameOf(255, 165, 0), 'laranja');
    });

    test('verde apagado de folha continua sendo verde', () {
      expect(namer.nameOf(86, 125, 70), 'verde');
      expect(namer.nameOf(85, 107, 47), 'verde-oliva');
    });

    test('a berinjela que o pacote antigo chamava de Melanzane', () {
      expect(namer.nameOf(86, 56, 79), 'vinho');
      expect(namer.nameOf(64, 32, 64), 'roxo escuro');
    });

    test('só devolve nomes que existem na paleta', () {
      final names = portuguesePalette.map((color) => color.name).toSet();

      for (var r = 0; r <= 255; r += 51) {
        for (var g = 0; g <= 255; g += 51) {
          for (var b = 0; b <= 255; b += 51) {
            expect(names, contains(namer.nameOf(r, g, b)));
          }
        }
      }
    });

    test('aceita uma paleta própria', () {
      final custom = ColorNamer(
        palette: const [
          NamedColor('claro', 255, 255, 255),
          NamedColor('escuro', 0, 0, 0),
        ],
      );

      expect(custom.nameOf(240, 240, 240), 'claro');
      expect(custom.nameOf(30, 30, 30), 'escuro');
    });
  });

  group('portuguesePalette', () {
    test('nomes todos em minúsculas e sem espaços sobrando', () {
      for (final color in portuguesePalette) {
        expect(color.name, color.name.trim().toLowerCase());
      }
    });

    test('referências com nomes diferentes não ficam coladas', () {
      for (final first in portuguesePalette) {
        for (final second in portuguesePalette) {
          if (first.name == second.name) {
            continue;
          }
          final distance = deltaE2000(
            Lab.fromRgb(first.red, first.green, first.blue),
            Lab.fromRgb(second.red, second.green, second.blue),
          );
          expect(
            distance,
            greaterThan(7),
            reason: '${first.name} e ${second.name} estão parecidas demais',
          );
        }
      }
    });
  });

  group('hexOf', () {
    test('formata em maiúsculas com dois dígitos por canal', () {
      expect(hexOf(30, 80, 220), '#1E50DC');
      expect(hexOf(0, 0, 0), '#000000');
      expect(hexOf(255, 255, 255), '#FFFFFF');
    });

    test('limita valores fora de 0 a 255', () {
      expect(hexOf(-5, 300, 15), '#00FF0F');
    });
  });
}
