import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';
import 'package:latlong2/latlong.dart';

class RouteState {
  final RouteModel? activeRoute;
  final List<LatLng> optimizedWaypoints;
  final int currentStopIndex;
  final bool isNavigating;

  const RouteState({
    this.activeRoute,
    this.optimizedWaypoints = const [],
    this.currentStopIndex = 0,
    this.isNavigating = false,
  });

  RouteState copyWith({RouteModel? activeRoute, List<LatLng>? optimizedWaypoints,
      int? currentStopIndex, bool? isNavigating}) => RouteState(
    activeRoute: activeRoute ?? this.activeRoute,
    optimizedWaypoints: optimizedWaypoints ?? this.optimizedWaypoints,
    currentStopIndex: currentStopIndex ?? this.currentStopIndex,
    isNavigating: isNavigating ?? this.isNavigating,
  );
}

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier() : super(const RouteState());

  void setRoute(RouteModel route, List<LatLng> waypoints) {
    state = state.copyWith(activeRoute: route, optimizedWaypoints: waypoints);
  }

  void startNavigation() => state = state.copyWith(isNavigating: true);
  void stopNavigation() => state = state.copyWith(isNavigating: false);

  void advanceToNextStop() {
    if (state.currentStopIndex < (state.activeRoute?.stops.length ?? 1) - 1) {
      state = state.copyWith(currentStopIndex: state.currentStopIndex + 1);
    }
  }
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((_) => RouteNotifier());
