class NumberUtils {
  static double clamp(double val, double min, double max) =>
      val < min ? min : (val > max ? max : val);

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static String compact(num n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  static double roundTo(double val, int decimals) {
    final f = 10.0 * decimals;
    return (val * f).roundToDouble() / f;
  }
}
