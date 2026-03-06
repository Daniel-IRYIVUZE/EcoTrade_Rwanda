class Validators {
  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w.]+@[\w]+\.\w+$').hasMatch(v)) return 'Enter a valid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? required(String? v, [String field = 'This field']) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Phone is required';
    if (!RegExp(r'^\+?[\d\s\-]{10,15}$').hasMatch(v)) return 'Enter a valid phone number';
    return null;
  }

  static String? positiveNumber(String? v, [String field = 'Value']) {
    if (v == null || v.isEmpty) return '$field is required';
    if (double.tryParse(v) == null) return '$field must be a number';
    if (double.parse(v) <= 0) return '$field must be positive';
    return null;
  }
}
