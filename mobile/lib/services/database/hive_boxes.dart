import 'package:hive/hive.dart';

class HiveBoxes {
  static const String listings = 'cached_listings';
  static const String routes = 'cached_routes';
  static const String pendingActions = 'pending_actions';
  static const String userData = 'user_data';
  static const String notifications = 'notifications';
  static const String bids = 'cached_bids';
  static const String collections = 'cached_collections';
  static const String settings = 'app_settings';

  static Future<void> openAll() async {
    await Hive.openBox(listings);
    await Hive.openBox(routes);
    await Hive.openBox(pendingActions);
    await Hive.openBox(userData);
    await Hive.openBox(notifications);
    await Hive.openBox(bids);
    await Hive.openBox(collections);
    await Hive.openBox(settings);
  }

  static Box get(String name) => Hive.box(name);
}
