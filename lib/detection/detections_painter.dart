import 'package:vera/detection/detection.dart';
import 'package:flutter/material.dart';

/// Desenha uma caixa grossa em volta de cada objeto, com o nome em letra
/// grande sobre fundo sólido, para quem enxerga pouco.
class DetectionsPainter extends CustomPainter {
  DetectionsPainter(this.detections);

  final List<Detection> detections;

  static const double _fontSize = 22;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..color = Colors.yellowAccent;
    final fill = Paint()..color = Colors.black;

    for (final detection in detections) {
      final box = Rect.fromLTRB(
        detection.box.left * size.width,
        detection.box.top * size.height,
        detection.box.right * size.width,
        detection.box.bottom * size.height,
      );
      canvas.drawRect(box, stroke);

      final text = TextPainter(
        text: TextSpan(
          text: '${detection.label} · ${detection.color}',
          style: const TextStyle(
            color: Colors.yellowAccent,
            fontSize: _fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: size.width);

      final top = (box.top - text.height - 6).clamp(0.0, size.height);
      final left = box.left.clamp(0.0, size.width - text.width - 12);
      canvas.drawRect(
        Rect.fromLTWH(left, top, text.width + 12, text.height + 6),
        fill,
      );
      text.paint(canvas, Offset(left + 6, top + 3));
    }
  }

  @override
  bool shouldRepaint(DetectionsPainter oldDelegate) =>
      oldDelegate.detections != detections;
}
