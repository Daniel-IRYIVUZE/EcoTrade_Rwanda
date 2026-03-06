import 'package:latlong2/latlong.dart';
import 'distance_calculator.dart' as geo;

class RoutingService {
  /// Nearest-neighbor TSP heuristic
  static List<LatLng> optimizeRoute(List<LatLng> stops, {LatLng? startPoint}) {
    if (stops.isEmpty) return [];
    final unvisited = List<LatLng>.from(stops);
    final route = <LatLng>[];
    LatLng current = startPoint ?? unvisited.removeAt(0);
    if (startPoint != null) route.add(startPoint);

    while (unvisited.isNotEmpty) {
      final nearest = geo.DistanceCalculator.nearestPoint(current, unvisited)!;
      unvisited.remove(nearest);
      route.add(nearest);
      current = nearest;
    }
    return route;
  }

  static double estimatedDurationMinutes(List<LatLng> route, {double avgSpeedKmh = 30}) {
    final distKm = geo.DistanceCalculator.totalRouteDistance(route) / 1000;
    return (distKm / avgSpeedKmh) * 60;
  }
}
