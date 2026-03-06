import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OfflineService {
  static const String _listingsBox = 'cached_listings';
  static const String _routesBox = 'cached_routes';
  static const String _pendingBox = 'pending_actions';
  static const String _userDataBox = 'user_data';
  
  static Future<void> init() async {
    await Hive.openBox(_listingsBox);
    await Hive.openBox(_routesBox);
    await Hive.openBox(_pendingBox);
    await Hive.openBox(_userDataBox);
  }
  
  static Future<void> cacheData(String key, dynamic data) async {
    final box = Hive.box(_listingsBox);
    await box.put(key, data);
  }
  
  static dynamic getCachedData(String key) {
    final box = Hive.box(_listingsBox);
    return box.get(key);
  }
  
  static Future<void> addPendingAction(Map<String, dynamic> action) async {
    final box = Hive.box(_pendingBox);
    final List pending = box.get('actions', defaultValue: []);
    pending.add({
      ...action,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await box.put('actions', pending);
  }
  
  static Future<void> syncPendingActions() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;
    
    final box = Hive.box(_pendingBox);
    final List pending = box.get('actions', defaultValue: []);
    
    for (var action in pending) {
      try {
        // TODO: Implement API sync
        await _syncAction(action);
      } catch (e) {
        debugPrint('Sync failed: $e');
      }
    }
    
    await box.delete('actions');
  }
  
  static Future<void> _syncAction(Map<String, dynamic> action) async {
    // Implement actual API call here
    await Future.delayed(const Duration(seconds: 1));
  }
  
  static Future<void> cacheRoute(String routeId, Map<String, dynamic> route) async {
    final box = Hive.box(_routesBox);
    await box.put('route_$routeId', {
      ...route,
      'cached_at': DateTime.now().toIso8601String(),
    });
  }
  
  static Map<String, dynamic>? getCachedRoute(String routeId) {
    final box = Hive.box(_routesBox);
    return box.get('route_$routeId');
  }
}