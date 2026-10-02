import 'dart:ui';

/// Um objeto encontrado no quadro.
class Detection {
  const Detection({
    required this.label,
    required this.score,
    required this.box,
    required this.color,
  });

  /// Nome do objeto em português.
  final String label;

  /// Confiança do detector, de 0 a 1.
  final double score;

  /// Caixa do objeto, com cada lado de 0 a 1 em relação à imagem em pé.
  final Rect box;

  /// Nome da cor predominante no objeto.
  final String color;

  /// Onde o objeto está na horizontal, pelo centro da caixa.
  String get position {
    final center = box.center.dx;
    if (center < 1 / 3) {
      return 'à esquerda';
    }
    if (center > 2 / 3) {
      return 'à direita';
    }
    return 'ao centro';
  }

  /// A frase falada, como "Cadeira, à esquerda, cor azul".
  String get description {
    final name = label[0].toUpperCase() + label.substring(1);
    return '$name, $position, cor $color';
  }
}
