import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(double amount, {String symbol = 'RWF'}) =>
      '$symbol ${NumberFormat('#,###').format(amount)}';

  static String weight(double kg) => '${kg.toStringAsFixed(1)} kg';

  static String distance(double meters) => meters >= 1000
      ? '${(meters / 1000).toStringAsFixed(1)} km'
      : '${meters.toStringAsFixed(0)} m';

  static String percentage(double value) => '${value.toStringAsFixed(1)}%';

  static String phone(String raw) => raw.replaceAllMapped(
      RegExp(r'(\d{3})(\d{3})(\d{4})'), (m) => '${m[1]} ${m[2]} ${m[3]}');
}
