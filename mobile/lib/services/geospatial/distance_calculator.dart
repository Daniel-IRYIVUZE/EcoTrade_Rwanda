import 'dart:math';
import 'package:latlong2/latlong.dart';

class DistanceCalculator {
  static const double _earthRadius = 6371000.0;

  static double haversineMeters(LatLng a, LatLng b) {
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) * cos(_toRad(b.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * _earthRadius * asin(sqrt(h));
  }

  static double haversineKm(LatLng a, LatLng b) => haversineMeters(a, b) / 1000;

  static double totalRouteDistance(List<LatLng> waypoints) {
    double total = 0;
    for (int i = 0; i < waypoints.length - 1; i++) {
      total += haversineMeters(waypoints[i], waypoints[i + 1]);
    }
    return total;
  }

  static double _toRad(double deg) => deg * pi / 180;

  static LatLng? nearestPoint(LatLng origin, List<LatLng> candidates) {
    if (candidates.isEmpty) return null;
    return candidates.reduce((a, b) =>
        haversineMeters(origin, a) < haversineMeters(origin, b) ? a : b);
  }
}
