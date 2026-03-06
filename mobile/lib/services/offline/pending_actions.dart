import '../database/hive_boxes.dart';

class PendingActions {
  static Future<void> add(Map<String, dynamic> action) async {
    final box = HiveBoxes.get(HiveBoxes.pendingActions);
    final list = List<Map>.from(box.get('actions', defaultValue: <Map>[]));
    list.add({...action, 'timestamp': DateTime.now().toIso8601String()});
    await box.put('actions', list);
  }

  static List<Map> getAll() {
    final box = HiveBoxes.get(HiveBoxes.pendingActions);
    return List<Map>.from(box.get('actions', defaultValue: <Map>[]));
  }

  static Future<void> clear() async {
    final box = HiveBoxes.get(HiveBoxes.pendingActions);
    await box.delete('actions');
  }

  static Future<void> remove(int index) async {
    final list = getAll();
    if (index < list.length) {
      list.removeAt(index);
      final box = HiveBoxes.get(HiveBoxes.pendingActions);
      await box.put('actions', list);
    }
  }
}
