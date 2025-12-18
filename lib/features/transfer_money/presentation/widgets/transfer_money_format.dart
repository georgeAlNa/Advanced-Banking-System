double parseAmount(String txt) {
  final v = double.tryParse(txt.trim()) ?? 0;
  return v < 0 ? 0 : v;
}

String formatMoney(double value) {
  final abs = value.abs().toStringAsFixed(2);
  return '\$$abs';
}
