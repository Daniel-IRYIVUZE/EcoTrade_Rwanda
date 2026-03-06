import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapMarkers {
  static Marker hotelMarker(LatLng pos, {String? label, VoidCallback? onTap}) => Marker(
    point: pos, width: 80, height: 60,
    child: GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: const Color(0xFF0F4C3A), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
          child: const Icon(Icons.hotel, color: Colors.white, size: 16),
        ),
        if (label != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]),
          child: Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ),
      ]),
    ),
  );

  static Marker driverMarker(LatLng pos) => Marker(
    point: pos, width: 48, height: 48,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const Icon(Icons.directions_car, color: Colors.white, size: 18),
    ),
  );

  static Marker recyclerMarker(LatLng pos) => Marker(
    point: pos, width: 48, height: 48,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
      child: const Icon(Icons.recycling, color: Colors.white, size: 18),
    ),
  );
}
