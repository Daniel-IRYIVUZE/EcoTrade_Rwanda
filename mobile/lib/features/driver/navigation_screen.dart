import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';
import '../../core/providers/app_providers.dart';
import '../shared/live_tracking_screen.dart';

class NavigationScreen extends ConsumerWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collections = ref.watch(driverCollectionsProvider);
    final started = collections
        .where((c) =>
            c.status == CollectionStatus.enRoute ||
            c.status == CollectionStatus.scheduled)
        .toList();
    final target = started.isNotEmpty
        ? started.first
        : (collections.isNotEmpty ? collections.first : null);

    if (target == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Navigation')),
        body: const Center(
          child: Text('No collections available for tracking.'),
        ),
      );
    }

    return LiveTrackingScreen(
      collection: target,
      pushDriverLocation: true,
    );
  }
}
