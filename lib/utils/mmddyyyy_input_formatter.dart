import 'package:flutter/services.dart';

/// Mem‐format input menjadi mm/dd/yyyy saat user mengetik.
/// Contoh: 1 → 1, 12 → 12/, 120 → 12/0, 1208 → 12/08/
/// Hingga maksimal 8 digit (mmddyyyy).
class MmDdYyyyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Hanya angka
    var digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 8) digits = digits.substring(0, 8);

    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      // Tambah '/' setelah 2 digit (mm) dan 2+2 digit (dd)
      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buffer.write('/');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      // Cursor selalu di akhir (paling simpel & stabil)
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}