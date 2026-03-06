import 'package:connectivity_plus/connectivity_plus.dart';
import 'pending_actions.dart';

class SyncService {
  static Future<void> sync() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final pending = PendingActions.getAll();
    final synced = <int>[];

    for (int i = 0; i < pending.length; i++) {
      try {
        await _processAction(pending[i]);
        synced.add(i);
      } catch (e) {
        // Skip failed, retry next sync
      }
    }

    // Remove synced in reverse order
    for (final index in synced.reversed) {
      await PendingActions.remove(index);
    }
  }

  static Future<void> _processAction(Map action) async {
    // TODO: Route to appropriate API service based on action type
    await Future.delayed(const Duration(milliseconds: 100));
  }

  static Stream<bool> get connectivityStream {
    return Connectivity().onConnectivityChanged
        .map((r) => r != ConnectivityResult.none);
  }
}
