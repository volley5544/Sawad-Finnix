import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Helpers for Thai national ID (13 digits) validation and display.
class ThaiId {
  ThaiId._();

  /// Returns the digits-only form (mask/dashes/spaces stripped).
  static String digitsOnly(String input) =>
      input.replaceAll(RegExp(r'\D'), '');

  /// SHA-256 hash (hex) of the digits-only national ID. Used as the stable,
  /// non-reversible identifier for the user (Firestore doc id / `uid`).
  static String hash(String pid) =>
      sha256.convert(utf8.encode(digitsOnly(pid))).toString();

  /// Validates a Thai national ID using the official checksum:
  /// the 13th digit is a check digit derived from the first 12.
  static bool isValid(String input) {
    final d = digitsOnly(input);
    if (d.length != 13) return false;
    var sum = 0;
    for (var i = 0; i < 12; i++) {
      sum += int.parse(d[i]) * (13 - i);
    }
    final check = (11 - (sum % 11)) % 10;
    return check == int.parse(d[12]);
  }

  /// Formats 13 digits as `#-####-#####-##-#`.
  static String mask(String input) {
    final d = digitsOnly(input);
    final capped = d.length > 13 ? d.substring(0, 13) : d;
    final b = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      // Dashes before index 1, 5, 10, 12 → groups of 1-4-5-2-1.
      if (i == 1 || i == 5 || i == 10 || i == 12) b.write('-');
      b.write(capped[i]);
    }
    return b.toString();
  }
}

/// [TextInputFormatter] that keeps only digits (max 13) and renders them in the
/// `#-####-#####-##-#` Thai national ID mask.
class ThaiIdInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = ThaiId.mask(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
