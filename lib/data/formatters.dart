int parseRupiah(String formattedPrice) => int.tryParse(formattedPrice.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String formatRupiah(int amount) {
  final digits = amount.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    buffer.write(digits[i]);
    final remaining = digits.length - i - 1;
    if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
  }
  return 'Rp ${buffer.toString()}';
}
