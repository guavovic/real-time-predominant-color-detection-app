import 'dart:ui';

import 'package:camera_cor_destaque/detection/detection.dart';
import 'package:camera_cor_destaque/detection/labels_pt.dart';
import 'package:flutter_test/flutter_test.dart';

Detection at(double left, double right) => Detection(
  label: 'cadeira',
  score: 0.9,
  box: Rect.fromLTRB(left, 0.2, right, 0.8),
  color: 'azul',
);

void main() {
  group('Detection.position', () {
    test('objeto no terço da esquerda', () {
      expect(at(0.0, 0.3).position, 'à esquerda');
    });

    test('objeto no meio', () {
      expect(at(0.4, 0.6).position, 'ao centro');
    });

    test('objeto no terço da direita', () {
      expect(at(0.7, 1.0).position, 'à direita');
    });

    test('centro logo depois dos dois terços já é da direita', () {
      expect(at(0.6, 0.8).position, 'à direita');
    });

    test('centro logo antes de um terço ainda é da esquerda', () {
      expect(at(0.2, 0.4).position, 'à esquerda');
    });

    test('objeto grande que passa do meio conta pelo centro da caixa', () {
      expect(at(0.0, 0.9).position, 'ao centro');
    });
  });

  test('a frase falada começa com maiúscula e diz posição e cor', () {
    expect(at(0.0, 0.3).description, 'Cadeira, à esquerda, cor azul');
  });

  group('cocoLabelsPt', () {
    test('tem uma posição por id do COCO, de 0 a 89', () {
      expect(cocoLabelsPt.length, 90);
    });

    test('as classes mais comuns estão nas posições do modelo', () {
      expect(cocoLabelsPt[0], 'pessoa');
      expect(cocoLabelsPt[61], 'cadeira');
      expect(cocoLabelsPt[76], 'celular');
    });
  });
}
