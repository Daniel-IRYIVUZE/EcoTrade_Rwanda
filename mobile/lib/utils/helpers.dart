class AppHelpers {
  static T? tryParse<T>(dynamic value, T Function(dynamic) parser) {
    try { return parser(value); } catch (_) { return null; }
  }

  static List<T> safeList<T>(dynamic json, T Function(Map<String, dynamic>) fromJson) {
    if (json == null) return [];
    try {
      return (json as List).map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) { return []; }
  }
}
