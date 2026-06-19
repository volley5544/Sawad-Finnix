import 'package:intl/intl.dart';

/// Shared formatting helpers (Thai locale).
class Formatters {
  Formatters._();

  static final NumberFormat _money = NumberFormat('#,##0.00');

  /// Formats an amount like `100,000.00`.
  static String money(num value) => _money.format(value);

  /// Formats a baht amount like `100,000.00 บาท`.
  static String baht(num value) => '${_money.format(value)} บาท';

  static const _thaiMonthsAbbr = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  /// Formats a date as `dd/MM/yyyy` using the Buddhist era year.
  static String thaiDate(DateTime d) {
    final y = d.year + 543;
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd/$mm/$y';
  }

  /// Short Thai month + Buddhist year, e.g. `ก.ค. 63`.
  static String thaiMonthYearShort(DateTime d) {
    final y = (d.year + 543) % 100;
    return '${_thaiMonthsAbbr[d.month - 1]} $y';
  }
}
