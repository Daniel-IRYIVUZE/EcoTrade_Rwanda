import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';

// ── Auth Provider ──────────────────────────────────────────────────────────

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;
  UserRole? get role => user?.role;

  AuthState copyWith({AppUser? user, bool? isLoading, String? error}) =>
      AuthState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 800));
    final user = DataService.instance.login(email, password);
    if (user != null) {
      state = AuthState(user: user);
      return true;
    } else {
      state = AuthState(error: 'Invalid email or password');
      return false;
    }
  }

  void logout() => state = const AuthState();
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(),
);

// ── Listings Providers ─────────────────────────────────────────────────────

final allListingsProvider = Provider<List<WasteListing>>(
  (ref) => DataService.instance.getListings(),
);

final openListingsProvider = Provider<List<WasteListing>>(
  (ref) => DataService.instance.getOpenListings(),
);

final businessListingsProvider = Provider<List<WasteListing>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return DataService.instance.getListingsForBusiness(user.id);
});

final recyclerBidListingsProvider = Provider<List<WasteListing>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return DataService.instance.getListingsWithBidsByRecycler(user.id);
});

// ── Collections Providers ─────────────────────────────────────────────────

final allCollectionsProvider = Provider<List<Collection>>(
  (ref) => DataService.instance.getCollections(),
);

final businessCollectionsProvider = Provider<List<Collection>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return DataService.instance.getCollectionsForBusiness(user.id);
});

final driverCollectionsProvider = Provider<List<Collection>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return DataService.instance.getCollectionsForDriver(user.id);
});

final recyclerCollectionsProvider = Provider<List<Collection>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return [];
  return DataService.instance.getCollectionsForRecycler(user.displayName);
});

// ── Driver Route Provider ─────────────────────────────────────────────────

final driverRouteProvider = Provider<DriverRoute>(
  (ref) => DataService.instance.getTodayRoute(),
);

// ── Transactions Provider ─────────────────────────────────────────────────

final transactionsProvider = Provider<List<Transaction>>(
  (ref) => DataService.instance.getTransactions(),
);

// ── Notifications Provider ────────────────────────────────────────────────

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(DataService.instance.getNotifications());

  int get unreadCount => state.where((n) => !n.read).length;

  void markRead(String id) {
    DataService.instance.markNotificationRead(id);
    state = DataService.instance.getNotifications();
  }

  void markAllRead() {
    DataService.instance.markAllNotificationsRead();
    state = DataService.instance.getNotifications();
  }

  void add(AppNotification n) {
    DataService.instance.addNotification(n);
    state = DataService.instance.getNotifications();
    NotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: n.title,
      body: n.message,
      type: n.type,
    );
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>(
  (ref) => NotificationsNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.read).length;
});

// ── Stats Providers ───────────────────────────────────────────────────────

final businessStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return {};
  return DataService.instance.getBusinessStats(user.id);
});

final recyclerStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return {};
  return DataService.instance.getRecyclerStats(user.id);
});

final driverStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return {};
  return DataService.instance.getDriverStats(user.id);
});
