import 'dart:math';
import 'package:latlong2/latlong.dart';

class GeospatialService {
  // DBSCAN Clustering Implementation
  static List<List<LatLng>> dbscanCluster(
    List<LatLng> points,
    double epsilon, // in meters
    int minPoints,
  ) {
    List<List<LatLng>> clusters = [];
    List<bool> visited = List.filled(points.length, false);
    List<bool> noise = List.filled(points.length, false);
    
    for (int i = 0; i < points.length; i++) {
      if (visited[i]) continue;
      
      visited[i] = true;
      List<int> neighbors = _getNeighbors(points, i, epsilon);
      
      if (neighbors.length < minPoints) {
        noise[i] = true;
      } else {
        List<LatLng> cluster = [points[i]];
        _expandCluster(points, visited, neighbors, cluster, epsilon, minPoints);
        clusters.add(cluster);
      }
    }
    
    return clusters;
  }
  
  static List<int> _getNeighbors(List<LatLng> points, int pointIndex, double epsilon) {
    List<int> neighbors = [];
    for (int i = 0; i < points.length; i++) {
      if (i == pointIndex) continue;
      
      double distance = _calculateDistance(
        points[pointIndex].latitude,
        points[pointIndex].longitude,
        points[i].latitude,
        points[i].longitude,
      );
      
      if (distance <= epsilon) {
        neighbors.add(i);
      }
    }
    return neighbors;
  }
  
  static void _expandCluster(
    List<LatLng> points,
    List<bool> visited,
    List<int> neighbors,
    List<LatLng> cluster,
    double epsilon,
    int minPoints,
  ) {
    for (int i = 0; i < neighbors.length; i++) {
      int pointIndex = neighbors[i];
      
      if (!visited[pointIndex]) {
        visited[pointIndex] = true;
        List<int> newNeighbors = _getNeighbors(points, pointIndex, epsilon);
        
        if (newNeighbors.length >= minPoints) {
          neighbors.addAll(newNeighbors.where((n) => !neighbors.contains(n)));
        }
      }
      
      if (!cluster.contains(points[pointIndex])) {
        cluster.add(points[pointIndex]);
      }
    }
  }
  
  // Traveling Salesman Problem (Nearest Neighbor Heuristic)
  static List<LatLng> optimizeRoute(List<LatLng> points) {
    if (points.isEmpty) return [];
    if (points.length == 1) return points;
    
    List<LatLng> unvisited = List.from(points);
    List<LatLng> route = [];
    
    // Start with first point
    LatLng current = unvisited.removeAt(0);
    route.add(current);
    
    while (unvisited.isNotEmpty) {
      // Find nearest unvisited point
      LatLng nearest = unvisited.reduce((a, b) {
        double distA = _calculateDistance(
          current.latitude,
          current.longitude,
          a.latitude,
          a.longitude,
        );
        double distB = _calculateDistance(
          current.latitude,
          current.longitude,
          b.latitude,
          b.longitude,
        );
        return distA < distB ? a : b;
      });
      
      route.add(nearest);
      unvisited.remove(nearest);
      current = nearest;
    }
    
    return route;
  }
  
  // Calculate cluster center (centroid)
  static LatLng calculateClusterCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    
    double sumLat = 0;
    double sumLng = 0;
    
    for (var point in points) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }
    
    return LatLng(
      sumLat / points.length,
      sumLng / points.length,
    );
  }
  
  // Find nearest recyclers within radius
  static List<Map<String, dynamic>> findNearestRecyclers(
    LatLng hotelLocation,
    List<Map<String, dynamic>> recyclers,
    double radiusKm,
  ) {
    List<Map<String, dynamic>> nearby = [];
    
    for (var recycler in recyclers) {
      LatLng recyclerLocation = LatLng(
        recycler['latitude'],
        recycler['longitude'],
      );
      
      double distance = _calculateDistance(
        hotelLocation.latitude,
        hotelLocation.longitude,
        recyclerLocation.latitude,
        recyclerLocation.longitude,
      ) / 1000; // Convert to km
      
      if (distance <= radiusKm) {
        nearby.add({
          ...recycler,
          'distance': distance,
        });
      }
    }
    
    // Sort by distance
    nearby.sort((a, b) => a['distance'].compareTo(b['distance']));
    return nearby;
  }
  
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) * cos(_degToRad(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }
  
  static double _degToRad(double deg) {
    return deg * pi / 180;
  }
  
  // Generate service area polygon
  static List<LatLng> generateServiceArea(
    LatLng center,
    double radiusKm,
    int numPoints,
  ) {
    List<LatLng> polygon = [];
    
    for (int i = 0; i < numPoints; i++) {
      double angle = (2 * pi * i) / numPoints;
      
      // Approximate conversion: 1 degree lat ≈ 111 km, 1 degree lon varies with latitude
      double latOffset = (radiusKm / 111) * cos(angle);
      double lonOffset = (radiusKm / (111 * cos(_degToRad(center.latitude)))) * sin(angle);
      
      polygon.add(LatLng(
        center.latitude + latOffset,
        center.longitude + lonOffset,
      ));
    }
    
    return polygon;
  }
}