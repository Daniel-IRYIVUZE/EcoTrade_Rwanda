class StringUtils {
  static String capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static String titleCase(String s) =>
      s.split(' ').map(capitalize).join(' ');

  static String initials(String name) =>
      name.trim().split(' ').take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join('');

  static bool isNullOrEmpty(String? s) => s == null || s.trim().isEmpty;

  static String truncate(String s, int max) =>
      s.length > max ? '${s.substring(0, max)}...' : s;
}
