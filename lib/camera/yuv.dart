/// Converte um pixel YUV (BT.601, faixa completa) em RGB, com cada canal de 0 a 255.
({int red, int green, int blue}) yuvToRgb(int y, int u, int v) {
  final cb = u - 128;
  final cr = v - 128;
  int clamp(double value) => value.round().clamp(0, 255);
  return (
    red: clamp(y + 1.402 * cr),
    green: clamp(y - 0.344136 * cb - 0.714136 * cr),
    blue: clamp(y + 1.772 * cb),
  );
}
