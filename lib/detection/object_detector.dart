import 'dart:ui';

import 'package:vera/camera/yuv_frame.dart';
import 'package:vera/color/color_namer.dart';
import 'package:vera/detection/detection.dart';
import 'package:vera/detection/frame_preprocessor.dart';
import 'package:vera/detection/labels_pt.dart';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// Acha objetos num quadro da câmera com o EfficientDet-Lite0 (COCO), no aparelho.
class ObjectDetector {
  ObjectDetector._(this._interpreter);

  static const String _modelAsset = 'assets/models/efficientdet_lite0.tflite';
  static const int _inputSize = 320;

  final Interpreter _interpreter;
  final ColorNamer _namer = ColorNamer();

  static Future<ObjectDetector> load() async {
    final interpreter = await Interpreter.fromAsset(
      _modelAsset,
      options: InterpreterOptions()..threads = 4,
    );
    return ObjectDetector._(interpreter);
  }

  /// Os objetos do [frame] com confiança de ao menos [minScore], do mais
  /// confiante para o menos. [rotation] é a orientação do sensor da câmera.
  List<Detection> detect(
    YuvFrame frame, {
    required int rotation,
    double minScore = 0.4,
  }) {
    final pixels = preprocessFrame(frame, size: _inputSize, rotation: rotation);
    _interpreter.runInference(<Object>[pixels]);

    if (!_mapOutputs()) {
      return const <Detection>[];
    }
    final boxes = _floats(_boxes);
    final classes = _floats(_classes);
    final scores = _floats(_scores);
    final count = _floats(_count)[0].round().clamp(0, scores.length);

    final found = <Detection>[];
    for (var i = 0; i < count; i++) {
      if (scores[i] < minScore) {
        continue;
      }
      final classId = classes[i].round();
      if (classId < 0 || classId >= cocoLabelsPt.length) {
        continue;
      }
      final label = cocoLabelsPt[classId];
      if (label.isEmpty) {
        continue;
      }
      final box = Rect.fromLTRB(
        boxes[i * 4 + 1].clamp(0.0, 1.0),
        boxes[i * 4].clamp(0.0, 1.0),
        boxes[i * 4 + 3].clamp(0.0, 1.0),
        boxes[i * 4 + 2].clamp(0.0, 1.0),
      );
      found.add(
        Detection(
          label: label,
          score: scores[i],
          box: box,
          color: _colorOf(pixels, box),
        ),
      );
    }
    return found;
  }

  void close() => _interpreter.close();

  int _boxes = -1;
  int _classes = -1;
  int _scores = -1;
  int _count = -1;

  /// O modelo devolve quatro saídas sem dizer qual é qual. Pelo formato dá pra
  /// achar as caixas e a contagem; das duas listas de números, a das classes é
  /// a que só tem valores inteiros.
  ///
  /// Devolve falso enquanto não dá pra decidir, o que acontece se as duas
  /// listas só tiverem inteiros (um quadro sem nenhum objeto).
  bool _mapOutputs() {
    if (_classes >= 0) {
      return true;
    }
    final lists = <int>[];
    for (var i = 0; i < 4; i++) {
      final shape = _interpreter.getOutputTensor(i).shape;
      if (shape.length == 3) {
        _boxes = i;
      } else if (shape.length == 1 || (shape.length == 2 && shape[1] == 1)) {
        _count = i;
      } else {
        lists.add(i);
      }
    }
    bool onlyIntegers(int i) => _floats(i).every((v) => v == v.roundToDouble());
    final first = onlyIntegers(lists[0]);
    if (first == onlyIntegers(lists[1])) {
      return false;
    }
    _classes = first ? lists[0] : lists[1];
    _scores = first ? lists[1] : lists[0];
    return true;
  }

  Float32List _floats(int outputIndex) {
    final data = _interpreter.getOutputTensor(outputIndex).data;
    return data.buffer.asFloat32List(
      data.offsetInBytes,
      data.lengthInBytes ~/ 4,
    );
  }

  /// A cor média da metade central da caixa, lida dos pixels já reduzidos.
  String _colorOf(Uint8List pixels, Rect box) {
    final inner = Rect.fromCenter(
      center: box.center,
      width: box.width / 2,
      height: box.height / 2,
    );
    final left = (inner.left * _inputSize).floor().clamp(0, _inputSize - 1);
    final right = (inner.right * _inputSize).ceil().clamp(left + 1, _inputSize);
    final top = (inner.top * _inputSize).floor().clamp(0, _inputSize - 1);
    final bottom = (inner.bottom * _inputSize).ceil().clamp(
      top + 1,
      _inputSize,
    );

    var red = 0;
    var green = 0;
    var blue = 0;
    var count = 0;
    for (var y = top; y < bottom; y++) {
      for (var x = left; x < right; x++) {
        final index = (y * _inputSize + x) * 3;
        red += pixels[index];
        green += pixels[index + 1];
        blue += pixels[index + 2];
        count++;
      }
    }
    return _namer.nameOf(red ~/ count, green ~/ count, blue ~/ count);
  }
}
