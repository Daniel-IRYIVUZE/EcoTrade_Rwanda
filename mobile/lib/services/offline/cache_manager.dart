import '../database/hive_boxes.dart';

class CacheManager {
  static Future<void> put(String boxName, String key, dynamic value) async {
    final box = HiveBoxes.get(boxName);
    await box.put(key, value);
  }

  static dynamic get(String boxName, String key, {dynamic defaultValue}) {
    final box = HiveBoxes.get(boxName);
    return box.get(key, defaultValue: defaultValue);
  }

  static Future<void> delete(String boxName, String key) async {
    final box = HiveBoxes.get(boxName);
    await box.delete(key);
  }

  static Future<void> clear(String boxName) async {
    final box = HiveBoxes.get(boxName);
    await box.clear();
  }

  static List<dynamic> getAll(String boxName) {
    final box = HiveBoxes.get(boxName);
    return box.values.toList();
  }
}
