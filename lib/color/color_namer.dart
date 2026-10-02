import 'package:camera_cor_destaque/color/cielab.dart';
import 'package:camera_cor_destaque/color/palette.dart';

/// Dá nome a uma cor escolhendo a cor de referência mais próxima da paleta,
/// medida pela diferença perceptual CIEDE2000.
class ColorNamer {
  ColorNamer({List<NamedColor> palette = portuguesePalette})
    : assert(palette.isNotEmpty, 'A paleta precisa ter ao menos uma cor.'),
      _palette = palette,
      _labs = <Lab>[
        for (final color in palette)
          Lab.fromRgb(color.red, color.green, color.blue),
      ];

  final List<NamedColor> _palette;
  final List<Lab> _labs;

  /// O nome da cor da paleta mais parecida com [red], [green], [blue] (0 a 255).
  String nameOf(int red, int green, int blue) {
    final target = Lab.fromRgb(red, green, blue);
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < _labs.length; i++) {
      final distance = deltaE2000(target, _labs[i]);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = i;
      }
    }
    return _palette[best].name;
  }
}

/// A cor em hexadecimal, como `#1E50DC`.
String hexOf(int red, int green, int blue) {
  String part(int channel) =>
      channel.clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase();
  return '#${part(red)}${part(green)}${part(blue)}';
}
