import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RoutePolyline {
  static Polyline buildRoute(List<LatLng> points, {Color color = const Color(0xFF10B981), double strokeWidth = 4}) {
    return Polyline(points: points, color: color, strokeWidth: strokeWidth, isDotted: false);
  }

  static Polyline buildDottedRoute(List<LatLng> points) {
    return Polyline(points: points, color: const Color(0xFF6B7280), strokeWidth: 2, isDotted: true);
  }
}
