import 'dart:math' as math;

/// Uma cor no espaço CIELAB (iluminante D65).
class Lab {
  const Lab(this.l, this.a, this.b);

  final double l;
  final double a;
  final double b;

  /// Converte uma cor sRGB (cada canal de 0 a 255) para CIELAB.
  factory Lab.fromRgb(int red, int green, int blue) {
    final r = _linear(red / 255);
    final g = _linear(green / 255);
    final bl = _linear(blue / 255);

    final x = (0.4124564 * r + 0.3575761 * g + 0.1804375 * bl) / 0.95047;
    final y = 0.2126729 * r + 0.7151522 * g + 0.0721750 * bl;
    final z = (0.0193339 * r + 0.1191920 * g + 0.9503041 * bl) / 1.08883;

    final fx = _f(x);
    final fy = _f(y);
    final fz = _f(z);

    return Lab(116 * fy - 16, 500 * (fx - fy), 200 * (fy - fz));
  }

  static double _linear(double channel) {
    return channel <= 0.04045
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }

  static double _f(double t) {
    const delta = 6 / 29;
    return t > delta * delta * delta
        ? math.pow(t, 1 / 3).toDouble()
        : t / (3 * delta * delta) + 4 / 29;
  }
}

/// Diferença de cor perceptual CIEDE2000 entre duas cores em CIELAB.
double deltaE2000(Lab first, Lab second) {
  final c1 = math.sqrt(first.a * first.a + first.b * first.b);
  final c2 = math.sqrt(second.a * second.a + second.b * second.b);
  final cMean = (c1 + c2) / 2;
  final cMean7 = math.pow(cMean, 7).toDouble();
  final g = 0.5 * (1 - math.sqrt(cMean7 / (cMean7 + math.pow(25, 7))));

  final a1 = (1 + g) * first.a;
  final a2 = (1 + g) * second.a;
  final cp1 = math.sqrt(a1 * a1 + first.b * first.b);
  final cp2 = math.sqrt(a2 * a2 + second.b * second.b);
  final hp1 = _hue(first.b, a1);
  final hp2 = _hue(second.b, a2);

  final dl = second.l - first.l;
  final dc = cp2 - cp1;
  var dh = 0.0;
  if (cp1 * cp2 != 0) {
    dh = hp2 - hp1;
    if (dh > 180) {
      dh -= 360;
    } else if (dh < -180) {
      dh += 360;
    }
  }
  final dH = 2 * math.sqrt(cp1 * cp2) * math.sin(_rad(dh) / 2);

  final lMean = (first.l + second.l) / 2;
  final cpMean = (cp1 + cp2) / 2;
  var hpMean = hp1 + hp2;
  if (cp1 * cp2 != 0) {
    if ((hp1 - hp2).abs() <= 180) {
      hpMean /= 2;
    } else if (hpMean < 360) {
      hpMean = (hpMean + 360) / 2;
    } else {
      hpMean = (hpMean - 360) / 2;
    }
  }

  final t =
      1 -
      0.17 * math.cos(_rad(hpMean - 30)) +
      0.24 * math.cos(_rad(2 * hpMean)) +
      0.32 * math.cos(_rad(3 * hpMean + 6)) -
      0.20 * math.cos(_rad(4 * hpMean - 63));
  final dTheta = 30 * math.exp(-math.pow((hpMean - 275) / 25, 2));
  final cpMean7 = math.pow(cpMean, 7).toDouble();
  final rc = 2 * math.sqrt(cpMean7 / (cpMean7 + math.pow(25, 7)));
  final lMinus50 = math.pow(lMean - 50, 2).toDouble();
  final sl = 1 + 0.015 * lMinus50 / math.sqrt(20 + lMinus50);
  final sc = 1 + 0.045 * cpMean;
  final sh = 1 + 0.015 * cpMean * t;
  final rt = -math.sin(_rad(2 * dTheta)) * rc;

  final lTerm = dl / sl;
  final cTerm = dc / sc;
  final hTerm = dH / sh;
  return math.sqrt(
    lTerm * lTerm + cTerm * cTerm + hTerm * hTerm + rt * cTerm * hTerm,
  );
}

double _hue(double b, double a) {
  if (b == 0 && a == 0) {
    return 0;
  }
  final degrees = math.atan2(b, a) * 180 / math.pi;
  return degrees >= 0 ? degrees : degrees + 360;
}

double _rad(double degrees) => degrees * math.pi / 180;
