import 'dart:math';
import 'package:latlong2/latlong.dart';

class ClusteringService {
  /// DBSCAN clustering for hotel locations
  static List<List<LatLng>> clusterHotels(
      List<LatLng> hotels, {double epsilonMeters = 1000, int minPoints = 2}) {
    List<List<LatLng>> clusters = [];
    List<bool> visited = List.filled(hotels.length, false);

    for (int i = 0; i < hotels.length; i++) {
      if (visited[i]) continue;
      visited[i] = true;
      final neighbors = _getNeighbors(hotels, i, epsilonMeters);
      if (neighbors.length >= minPoints - 1) {
        final cluster = [hotels[i]];
        _expand(hotels, visited, neighbors, cluster, epsilonMeters, minPoints);
        clusters.add(cluster);
      }
    }
    return clusters;
  }

  static List<int> _getNeighbors(List<LatLng> points, int idx, double eps) {
    return [
      for (int i = 0; i < points.length; i++)
        if (i != idx && _haversineMeters(points[idx], points[i]) <= eps) i
    ];
  }

  static void _expand(List<LatLng> points, List<bool> visited,
      List<int> neighbors, List<LatLng> cluster, double eps, int min) {
    for (int i = 0; i < neighbors.length; i++) {
      final idx = neighbors[i];
      if (!visited[idx]) {
        visited[idx] = true;
        final nn = _getNeighbors(points, idx, eps);
        if (nn.length >= min - 1) neighbors.addAll(nn.where((n) => !neighbors.contains(n)));
      }
      if (!cluster.contains(points[idx])) cluster.add(points[idx]);
    }
  }

  static double _haversineMeters(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLng = _toRad(b.longitude - a.longitude);
    final h = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(a.latitude)) * cos(_toRad(b.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    return 2 * R * asin(sqrt(h));
  }

  static double _toRad(double deg) => deg * pi / 180;

  static LatLng centroid(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    final lat = points.map((p) => p.latitude).reduce((a, b) => a + b) / points.length;
    final lng = points.map((p) => p.longitude).reduce((a, b) => a + b) / points.length;
    return LatLng(lat, lng);
  }
}
